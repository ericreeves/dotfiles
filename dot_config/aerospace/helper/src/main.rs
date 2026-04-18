use std::collections::HashMap;
use std::fs;
use std::io::{BufRead, BufReader, Write};
use std::os::unix::net::{UnixListener, UnixStream};
use std::process::Command;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

use std::ptr::NonNull;

use block2::RcBlock;
use objc2_app_kit::NSWorkspace;
use objc2_foundation::NSNotification;
use serde::Deserialize;
use notify::{Watcher, RecursiveMode, Event, EventKind};
use std::path::Path;

const SOCKET_PATH: &str = "/tmp/aerospace-helper.sock";
const PID_PATH: &str = "/tmp/aerospace-helper.pid";
const G9_PATTERN: &str = "Odyssey";
const CONFIG_PATH: &str = "/Users/eric/.config/aerospace/aerospace.toml";
const ICON_MAP_PATH: &str = "/Users/eric/.config/aerospace/sketchybar/icon_map.toml";

// Gap values
const GAP_NORMAL: &str = "15";
const GAP_CENTERED: &str = "1280";

// Debounce: minimum ms between processing the same event type
const DEBOUNCE_MS: u64 = 150;
// Max concurrent spawned processes before we start dropping events
const MAX_CHILD_PROCS: usize = 20;

// --- TOML deserialization structs ---

#[derive(Deserialize, Default)]
struct AerospaceConfig {
    #[serde(rename = "on-window-detected", default)]
    on_window_detected: Vec<WindowDetectedRule>,
}

#[derive(Deserialize, Default)]
struct WindowDetectedRule {
    #[serde(rename = "if", default)]
    condition: WindowCondition,
    #[serde(default)]
    run: String,
}

#[derive(Deserialize, Default)]
struct WindowCondition {
    #[serde(rename = "app-name-regex-substring", default)]
    app_name_regex_substring: Option<String>,
    #[serde(rename = "app-id", default)]
    app_id: Option<String>,
}

#[derive(Deserialize, Default)]
struct IconMapConfig {
    #[serde(default)]
    icons: HashMap<String, String>,
}

fn load_floating_patterns() -> Vec<String> {
    let content = match fs::read_to_string(CONFIG_PATH) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("[helper] failed to read aerospace config: {}", e);
            return Vec::new();
        }
    };
    let config: AerospaceConfig = match toml::from_str(&content) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("[helper] failed to parse aerospace config: {}", e);
            return Vec::new();
        }
    };
    config.on_window_detected
        .into_iter()
        .filter(|rule| rule.run.contains("layout floating"))
        .filter_map(|rule| rule.condition.app_name_regex_substring)
        .collect()
}

fn load_icon_map() -> HashMap<String, String> {
    let content = match fs::read_to_string(ICON_MAP_PATH) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("[helper] failed to read icon map: {}", e);
            return HashMap::new();
        }
    };
    let config: IconMapConfig = match toml::from_str(&content) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("[helper] failed to parse icon map: {}", e);
            return HashMap::new();
        }
    };
    config.icons
}

#[derive(Debug, Clone, PartialEq)]
enum GapState {
    Normal,
    Centered,
}

struct HelperState {
    gap_state: GapState,
    last_reload: Instant,
    is_retiling: bool,
    last_event_times: HashMap<String, Instant>,
    child_count: usize,
    floating_app_patterns: Vec<String>,
    icon_map: HashMap<String, String>,
    sketchybar_items: HashMap<String, Vec<String>>,  // workspace -> dynamic item names
}

impl HelperState {
    fn new() -> Self {
        let floating_app_patterns = load_floating_patterns();
        let icon_map = load_icon_map();
        eprintln!("[helper] loaded {} floating patterns, {} icon mappings",
            floating_app_patterns.len(), icon_map.len());
        Self {
            gap_state: GapState::Normal,
            last_reload: Instant::now() - Duration::from_secs(10),
            is_retiling: false,
            last_event_times: HashMap::new(),
            child_count: 0,
            floating_app_patterns,
            icon_map,
            sketchybar_items: HashMap::new(),
        }
    }

    /// Returns true if this event type should be processed (not debounced).
    fn should_process(&mut self, event_key: &str) -> bool {
        let now = Instant::now();
        if let Some(last) = self.last_event_times.get(event_key) {
            if now.duration_since(*last) < Duration::from_millis(DEBOUNCE_MS) {
                return false;
            }
        }
        self.last_event_times.insert(event_key.to_string(), now);
        true
    }

    fn is_floating_app(&self, app_name: &str) -> bool {
        self.floating_app_patterns.iter().any(|pattern| {
            app_name.to_lowercase().contains(&pattern.to_lowercase())
        })
    }

    fn get_icon(&self, app_name: &str) -> &str {
        self.icon_map.get(app_name)
            .or_else(|| self.icon_map.get("_default"))
            .map(|s| s.as_str())
            .unwrap_or(":default:")
    }
}

// Global flag for signal-driven shutdown
static SHUTDOWN: AtomicBool = AtomicBool::new(false);

// --- Aerospace CLI ---

fn aerospace_cmd(args: &[&str]) -> Option<String> {
    let output = Command::new("/opt/homebrew/bin/aerospace")
        .args(args)
        .output()
        .ok()?;
    if output.status.success() {
        Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
    } else {
        None
    }
}

fn is_on_g9(workspace: &str) -> bool {
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace, "--format", "%{monitor-name}",
    ]).unwrap_or_default();

    if let Some(first) = output.lines().next() {
        if !first.is_empty() {
            return first.contains(G9_PATTERN);
        }
    }

    // Fallback: check workspace-to-monitor mapping
    let monitors = aerospace_cmd(&[
        "list-monitors", "--format", "%{monitor-id}|%{monitor-name}",
    ]).unwrap_or_default();

    for line in monitors.lines() {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 2 { continue; }
        let workspaces = aerospace_cmd(&[
            "list-workspaces", "--monitor", parts[0], "--format", "%{workspace}",
        ]).unwrap_or_default();
        if workspaces.lines().any(|ws| ws == workspace) {
            return parts[1].contains(G9_PATTERN);
        }
    }
    false
}

fn get_hidden_bundle_ids() -> Vec<String> {
    let workspace = NSWorkspace::sharedWorkspace();
    let apps = workspace.runningApplications();
    let mut hidden = Vec::new();
    for app in apps.iter() {
        if app.isHidden() {
            if let Some(bid) = app.bundleIdentifier() {
                hidden.push(bid.to_string());
            }
        }
    }
    hidden
}

fn count_visible_windows(workspace: &str, state: &HelperState) -> usize {
    let hidden = get_hidden_bundle_ids();
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{app-name}|%{app-bundle-id}",
    ]).unwrap_or_default();

    output.lines().filter(|line| {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 2 { return false; }
        let app_name = parts[0].trim();
        let bid = parts[1].trim();
        !app_name.is_empty()
            && !hidden.contains(&bid.to_string())
            && !state.is_floating_app(app_name)
    }).count()
}

/// Retile all visible (non-hidden, non-floating) windows on a workspace.
/// Sets is_retiling flag to prevent focus_changed feedback loop.
fn retile_all_visible(workspace: &str, state_arc: &Arc<Mutex<HelperState>>) {
    // Set the retile guard
    {
        let mut s = state_arc.lock().unwrap();
        s.is_retiling = true;
    }

    let hidden = get_hidden_bundle_ids();
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{window-id}|%{app-name}|%{app-bundle-id}",
    ]).unwrap_or_default();

    let floating_apps: Vec<String>;
    {
        let s = state_arc.lock().unwrap();
        floating_apps = s.floating_app_patterns.clone();
    }

    for line in output.lines() {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 3 { continue; }
        let wid = parts[0].trim();
        let app_name = parts[1].trim();
        let bid = parts[2].trim();
        if wid.is_empty() || hidden.contains(&bid.to_string()) {
            continue;
        }
        // Check floating using patterns directly (avoid re-locking in loop)
        let is_floating = floating_apps.iter().any(|pattern| {
            app_name.to_lowercase().contains(&pattern.to_lowercase())
        });
        if is_floating { continue; }
        let _ = aerospace_cmd(&["layout", "--window-id", wid, "tiling"]);
    }

    // Clear the retile guard
    {
        let mut s = state_arc.lock().unwrap();
        s.is_retiling = false;
    }

    eprintln!("[helper] retiled all visible windows on ws{}", workspace);
}

fn float_hidden_windows(workspace: &str, _state: &HelperState) {
    let hidden = get_hidden_bundle_ids();
    if hidden.is_empty() { return; }
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{window-id}|%{app-bundle-id}",
    ]).unwrap_or_default();

    for line in output.lines() {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 2 { continue; }
        if hidden.contains(&parts[1].to_string()) {
            let _ = aerospace_cmd(&["layout", "--window-id", parts[0].trim(), "floating"]);
        }
    }
}

// --- Gap management via config editing ---

fn apply_gaps(target: &GapState) {
    // Read the config file
    let config = match fs::read_to_string(CONFIG_PATH) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("[helper] failed to read config: {}", e);
            return;
        }
    };

    // Replace outer.left and outer.right with per-monitor syntax
    // so only the main monitor (G9) gets large gaps, secondary stays at 15
    let formatted = match target {
        GapState::Centered => format!("[{{ monitor.'main' = {} }}, {}]", GAP_CENTERED, GAP_NORMAL),
        GapState::Normal => GAP_NORMAL.to_string(),
    };

    let mut new_config = String::new();
    for line in config.lines() {
        let trimmed = line.trim_start();
        if trimmed.starts_with("outer.left") {
            new_config.push_str(&format!("    outer.left = {}\n", formatted));
        } else if trimmed.starts_with("outer.right") {
            new_config.push_str(&format!("    outer.right = {}\n", formatted));
        } else {
            new_config.push_str(line);
            new_config.push('\n');
        }
    }

    // Write back
    if let Err(e) = fs::write(CONFIG_PATH, &new_config) {
        eprintln!("[helper] failed to write config: {}", e);
        return;
    }

    // Reload aerospace config
    let _ = aerospace_cmd(&["reload-config"]);

    eprintln!("[helper] gaps set to {:?}", target);
}

// --- Spawn external commands with cleanup ---

/// Spawn a fire-and-forget command, but reap the child to prevent zombies.
/// Returns false if we're at the child process limit.
fn spawn_and_reap(cmd: &str, args: &[&str], state: &Arc<Mutex<HelperState>>) -> bool {
    {
        let s = state.lock().unwrap();
        if s.child_count >= MAX_CHILD_PROCS {
            eprintln!("[helper] WARNING: child process limit ({}) reached, dropping spawn of {}", MAX_CHILD_PROCS, cmd);
            return false;
        }
    }

    let child = Command::new(cmd).args(args).spawn();
    match child {
        Ok(mut child) => {
            let state = Arc::clone(state);
            {
                let mut s = state.lock().unwrap();
                s.child_count += 1;
            }
            thread::spawn(move || {
                let _ = child.wait();
                let mut s = state.lock().unwrap();
                s.child_count = s.child_count.saturating_sub(1);
            });
            true
        }
        Err(e) => {
            eprintln!("[helper] failed to spawn {}: {}", cmd, e);
            false
        }
    }
}

fn spawn_bash_and_reap(script: &str, state: &Arc<Mutex<HelperState>>) -> bool {
    spawn_and_reap("/bin/bash", &["-c", script], state)
}

fn spawn_and_reap_closure<F>(f: F, state: &Arc<Mutex<HelperState>>)
where F: FnOnce() + Send + 'static {
    {
        let s = state.lock().unwrap();
        if s.child_count >= MAX_CHILD_PROCS {
            eprintln!("[helper] WARNING: child limit reached, dropping closure spawn");
            return;
        }
    }
    let state = Arc::clone(state);
    {
        let mut s = state.lock().unwrap();
        s.child_count += 1;
    }
    thread::spawn(move || {
        f();
        let mut s = state.lock().unwrap();
        s.child_count = s.child_count.saturating_sub(1);
    });
}

// --- Event handling ---

fn update_borders(state: &Arc<Mutex<HelperState>>) {
    // Query focused window state for dynamic border color
    let state_info = aerospace_cmd(&[
        "list-windows", "--focused",
        "--format", "%{window-layout}|%{window-is-fullscreen}",
    ]).unwrap_or_default();

    let parts: Vec<&str> = state_info.lines().next().unwrap_or("").split('|').collect();
    let layout = parts.first().unwrap_or(&"");
    let is_fullscreen = parts.get(1).unwrap_or(&"false") == &"true";

    // Catppuccin Mocha border colors by state
    let active_color = if is_fullscreen {
        "0xff89b4fa"  // Blue — fullscreen
    } else if layout.contains("accordion") {
        "0xffa6e3a1"  // Green — accordion/stacked
    } else if *layout == "floating" {
        "0xffcba6f7"  // Mauve — floating
    } else {
        "glow(0xffb4befe)"  // Lavender glow — normal tiling
    };

    let cmd = format!(
        "/opt/homebrew/bin/borders active_color=\"{}\" inactive_color=\"0xff11111b\"",
        active_color
    );
    spawn_bash_and_reap(&cmd, state);
}

fn update_sketchybar(focused_workspace: &str, state_arc: &Arc<Mutex<HelperState>>) {
    // Snapshot what we need from state, then drop the lock immediately
    let (floating_patterns, icon_map, prev_items) = {
        let state = state_arc.lock().unwrap();
        (state.floating_app_patterns.clone(), state.icon_map.clone(), state.sketchybar_items.clone())
    };

    let hidden = get_hidden_bundle_ids();

    // Query ALL windows with layout, container, and tree index
    let all_windows = aerospace_cmd(&[
        "list-windows", "--all",
        "--format", "%{workspace}|%{app-name}|%{app-bundle-id}|%{window-layout}|%{window-parent-container-id}|%{window-tree-index}",
    ]).unwrap_or_default();

    // Query focused window's app name to highlight its icon
    let focused_app = aerospace_cmd(&[
        "list-windows", "--focused", "--format", "%{app-name}",
    ]).unwrap_or_default();

    // Query workspace-to-monitor mapping (only if multi-monitor)
    let monitor_count: usize = aerospace_cmd(&["list-monitors", "--count"])
        .and_then(|s| s.trim().parse().ok())
        .unwrap_or(1);

    let ws_monitors: HashMap<String, String> = if monitor_count > 1 {
        aerospace_cmd(&["list-workspaces", "--monitor", "all", "--format", "%{workspace}|%{monitor-id}"])
            .unwrap_or_default()
            .lines()
            .filter_map(|line| {
                let parts: Vec<&str> = line.split('|').collect();
                if parts.len() == 2 { Some((parts[0].to_string(), parts[1].to_string())) } else { None }
            })
            .collect()
    } else {
        HashMap::new()
    };

    // Helper closures using the snapshots
    let is_floating = |app_name: &str| -> bool {
        floating_patterns.iter().any(|p| app_name.to_lowercase().contains(&p.to_lowercase()))
    };
    let get_icon = |app_name: &str| -> &str {
        icon_map.get(app_name)
            .or_else(|| icon_map.get("_default"))
            .map(|s| s.as_str())
            .unwrap_or(":default:")
    };

    // Parse windows into per-workspace ordered lists
    struct WindowInfo {
        app_name: String,
        layout: String,
        container_id: String,
        tree_index: i32,
    }
    let mut ws_windows: HashMap<String, Vec<WindowInfo>> = HashMap::new();
    for line in all_windows.lines() {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 6 { continue; }
        let ws = parts[0].trim();
        let app_name = parts[1].trim();
        let bid = parts[2].trim();
        let layout = parts[3].trim();
        let container_id = parts[4].trim();
        let tree_index: i32 = parts[5].trim().parse().unwrap_or(999);
        if app_name.is_empty() { continue; }
        if hidden.contains(&bid.to_string()) { continue; }
        if is_floating(app_name) { continue; }
        ws_windows.entry(ws.to_string()).or_default().push(WindowInfo {
            app_name: app_name.to_string(),
            layout: layout.to_string(),
            container_id: container_id.to_string(),
            tree_index,
        });
    }

    // Sort each workspace's windows by tree index (visual order)
    for windows in ws_windows.values_mut() {
        windows.sort_by_key(|w| w.tree_index);
    }

    // Build groups per workspace, preserving tree order
    struct IconGroup {
        icons: Vec<String>,
        is_accordion: bool,
        has_focused: bool,
    }
    let mut ws_groups: HashMap<String, Vec<IconGroup>> = HashMap::new();
    for (ws, windows) in &ws_windows {
        let mut groups: Vec<IconGroup> = Vec::new();
        let mut seen_containers: std::collections::HashSet<String> = std::collections::HashSet::new();
        for win in windows {
            let is_accordion = win.layout.contains("accordion");
            if is_accordion {
                if seen_containers.contains(&win.container_id) {
                    continue; // Already emitted this accordion group
                }
                seen_containers.insert(win.container_id.clone());
                // Collect ALL windows with this container_id
                let container_windows: Vec<&WindowInfo> = windows.iter()
                    .filter(|w| w.container_id == win.container_id)
                    .collect();
                let has_focused = container_windows.iter().any(|w| w.app_name == focused_app);
                let group_icons: Vec<String> = container_windows.iter()
                    .map(|w| get_icon(&w.app_name).to_string())
                    .collect();
                groups.push(IconGroup { icons: group_icons, is_accordion: true, has_focused });
            } else {
                let has_focused = win.app_name == focused_app;
                groups.push(IconGroup {
                    icons: vec![get_icon(&win.app_name).to_string()],
                    is_accordion: false,
                    has_focused,
                });
            }
        }
        ws_groups.insert(ws.clone(), groups);
    }

    // Build batched sketchybar command args
    let mut args: Vec<String> = Vec::new();
    let mut new_items: HashMap<String, Vec<String>> = HashMap::new();

    for sid in 1..=9 {
        let sid_str = sid.to_string();
        let is_focused = sid_str == focused_workspace;
        let bg_color = if is_focused { "0xff313244" } else { "0x00000000" };
        let highlight = if is_focused { "on" } else { "off" };
        let label_color = if is_focused { "0xffcdd6f4" } else { "0xff6c7086" };

        // Update the static space.{sid} item — clear label, set highlight
        // Background now comes from the bracket, so disable it on the item itself
        args.extend([
            "--set".to_string(), format!("space.{}", sid),
            "label=".to_string(),
            format!("icon.highlight={}", highlight),
            format!("label.highlight={}", highlight),
            "background.drawing=off".to_string(),
            "icon.padding_right=5".to_string(),
            "label.padding_left=0".to_string(),
            "label.padding_right=0".to_string(),
        ]);

        if monitor_count > 1 {
            if let Some(mid) = ws_monitors.get(&sid_str) {
                args.push(format!("associated_display={}", mid));
            }
        } else {
            args.push("associated_display=1".to_string());
        }

        // Create dynamic items for each icon group
        let groups = ws_groups.get(&sid_str);
        let mut item_names: Vec<String> = Vec::new();
        if let Some(groups) = groups {
            // Track the last placed item so we can chain --move after it
            let mut move_after = format!("space.{}", sid);
            for (idx, group) in groups.iter().enumerate() {
                let item_name = format!("ws{}.g{}", sid, idx);
                let label = group.icons.join(" ");
                // Focused item gets bright color, others get dim
                let item_color = if group.has_focused { "0xffcdd6f4" } else { "0xff6c7086" };

                // Add item and set properties
                args.extend([
                    "--add".to_string(), "item".to_string(), item_name.clone(), "center".to_string(),
                    "--set".to_string(), item_name.clone(),
                    format!("label={}", label),
                    format!("label.color={}", item_color),
                    "label.font=sketchybar-app-font:Regular:13.0".to_string(),
                    "label.y_offset=0".to_string(),
                    "icon.drawing=off".to_string(),
                    "label.padding_left=4".to_string(),
                    "label.padding_right=4".to_string(),
                ]);

                if group.is_accordion {
                    args.extend([
                        "background.drawing=on".to_string(),
                        "background.color=0xff45475a".to_string(),
                        "background.corner_radius=8".to_string(),
                        "background.border_width=0".to_string(),
                        "background.height=26".to_string(),
                        "background.padding_left=2".to_string(),
                        "background.padding_right=2".to_string(),
                    ]);
                } else {
                    args.push("background.drawing=off".to_string());
                }

                if monitor_count > 1 {
                    if let Some(mid) = ws_monitors.get(&sid_str) {
                        args.push(format!("associated_display={}", mid));
                    }
                } else {
                    args.push("associated_display=1".to_string());
                }

                // Position after the previous item to maintain tree order
                args.extend([
                    "--move".to_string(), item_name.clone(),
                    "after".to_string(), move_after,
                ]);

                move_after = item_name.clone();
                item_names.push(item_name);
            }
        }
        // Create bracket around workspace number + all icon items
        let bracket_name = format!("ws{}.bracket", sid);
        if !item_names.is_empty() {
            let mut bracket_members: Vec<String> = vec![format!("space.{}", sid)];
            bracket_members.extend(item_names.iter().cloned());
            args.push("--add".to_string());
            args.push("bracket".to_string());
            args.push(bracket_name.clone());
            args.extend(bracket_members);
            args.extend([
                "--set".to_string(), bracket_name.clone(),
                format!("background.color={}", bg_color),
                "background.corner_radius=8".to_string(),
                "background.height=26".to_string(),
                "background.drawing=on".to_string(),
            ]);
        } else {
            // No icons — just show workspace number with its own background
            args.extend([
                "--set".to_string(), format!("space.{}", sid),
                "background.drawing=on".to_string(),
                format!("background.color={}", bg_color),
            ]);
            // Remove bracket if it existed
            args.extend(["--remove".to_string(), bracket_name.clone()]);
        }

        item_names.push(bracket_name);
        new_items.insert(sid_str, item_names);
    }

    // Remove stale items from previous update
    for (ws, old_names) in &prev_items {
        let current_names = new_items.get(ws).cloned().unwrap_or_default();
        for name in old_names {
            if !current_names.contains(name) {
                args.extend(["--remove".to_string(), name.clone()]);
            }
        }
    }

    // Store new item names in state
    {
        let mut state = state_arc.lock().unwrap();
        state.sketchybar_items = new_items;
    }

    let args_refs: Vec<&str> = args.iter().map(|s| s.as_str()).collect();
    spawn_and_reap("/opt/homebrew/bin/sketchybar", &args_refs, state_arc);
}

fn handle_gaps(workspace: &str, state_arc: &Arc<Mutex<HelperState>>) {
    if !is_on_g9(workspace) {
        // G9 not connected or workspace not on G9 — ensure gaps are Normal
        // so the MBP doesn't get stuck with 1280px centered gaps
        let current_state = {
            let s = state_arc.lock().unwrap();
            s.gap_state.clone()
        };
        if current_state == GapState::Centered {
            eprintln!("[helper] G9 not detected, resetting gaps to Normal");
            {
                let mut s = state_arc.lock().unwrap();
                s.gap_state = GapState::Normal;
            }
            spawn_and_reap_closure(move || { apply_gaps(&GapState::Normal); }, state_arc);
        }
        return;
    }

    // Get floating patterns snapshot (brief lock)
    let floating_patterns = {
        let s = state_arc.lock().unwrap();
        s.floating_app_patterns.clone()
    };

    // These call aerospace_cmd — no lock held
    float_hidden_windows_with_patterns(workspace, &floating_patterns);
    let count = count_visible_windows_with_patterns(workspace, &floating_patterns);

    // Brief lock to check and update gap state
    let mut s = state_arc.lock().unwrap();
    eprintln!("[helper] ws{}: {} visible windows, gaps={:?}", workspace, count, s.gap_state);

    let target = if count <= 1 { GapState::Centered } else { GapState::Normal };
    if target == s.gap_state { return; }
    s.gap_state = target.clone();
    drop(s);

    let target_clone = target;
    spawn_and_reap_closure(move || { apply_gaps(&target_clone); }, state_arc);
}

fn count_visible_windows_with_patterns(workspace: &str, floating_patterns: &[String]) -> usize {
    let hidden = get_hidden_bundle_ids();
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{app-name}|%{app-bundle-id}",
    ]).unwrap_or_default();

    output.lines().filter(|line| {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 2 { return false; }
        let app_name = parts[0].trim();
        let bid = parts[1].trim();
        !app_name.is_empty()
            && !hidden.contains(&bid.to_string())
            && !floating_patterns.iter().any(|p| app_name.to_lowercase().contains(&p.to_lowercase()))
    }).count()
}

fn float_hidden_windows_with_patterns(workspace: &str, floating_patterns: &[String]) {
    let hidden = get_hidden_bundle_ids();
    if hidden.is_empty() { return; }
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{window-id}|%{app-bundle-id}",
    ]).unwrap_or_default();

    for line in output.lines() {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 2 { continue; }
        if hidden.contains(&parts[1].to_string()) {
            let _ = aerospace_cmd(&["layout", "--window-id", parts[0].trim(), "floating"]);
        }
    }
}

fn handle_event(raw_event: &str, state_arc: &Arc<Mutex<HelperState>>, ws_tx: &mpsc::Sender<String>) {
    let (event, workspace) = if let Some((ev, ws)) = raw_event.split_once(':') {
        (ev.to_string(), ws.to_string())
    } else {
        let ws = match aerospace_cmd(&["list-workspaces", "--focused"]) {
            Some(ws) => ws,
            None => return,
        };
        (raw_event.to_string(), ws)
    };

    // Debounce: skip if we processed this event type too recently
    // Don't debounce workspace_changed — each switch needs processing even if rapid
    if event != "workspace_changed" {
        let mut s = state_arc.lock().unwrap();
        if !s.should_process(&event) {
            eprintln!("[helper] debounced event={} workspace={}", event, workspace);
            return;
        }
    }

    eprintln!("[helper] event={} workspace={}", event, workspace);

    match event.as_str() {
        "workspace_changed" => {
            // Send to the workspace worker thread (serialized, no concurrent aerospace_cmd)
            let _ = ws_tx.send(workspace);
        }
        "focus_changed" => {
            // If we're in the middle of a retile, ignore focus changes to break the loop
            {
                let s = state_arc.lock().unwrap();
                if s.is_retiling {
                    eprintln!("[helper] suppressed focus_changed during retile");
                    return;
                }
            }
            update_borders(state_arc);
            // Update sketchybar to highlight the focused window's group
            update_sketchybar(&workspace, state_arc);
        }
        "app_visibility_changed" => {
            // Fired by NSWorkspace observer when an app is hidden/unhidden/quit/launched
            // Route through the workspace worker to avoid concurrent aerospace_cmd calls
            eprintln!("[helper] app visibility changed, sending to worker");
            let _ = ws_tx.send("__visibility__".to_string());
        }
        "retile" => {
            eprintln!("[helper] retile request for ws{}", workspace);
            let _ = ws_tx.send(workspace);
        }
        _ => {}
    }
}

fn handle_client(stream: UnixStream, state: Arc<Mutex<HelperState>>, ws_tx: mpsc::Sender<String>) {
    let reader = BufReader::new(stream);
    for line in reader.lines() {
        if let Ok(event) = line {
            let event = event.trim().to_string();
            if event.is_empty() { continue; }
            handle_event(&event, &state, &ws_tx);
        }
    }
}

/// Send an event to ourselves via the Unix socket
fn send_self_event(event: &str) {
    if let Ok(mut stream) = UnixStream::connect(SOCKET_PATH) {
        let _ = writeln!(stream, "{}", event);
    }
}

fn cleanup_and_exit() {
    let _ = fs::remove_file(SOCKET_PATH);
    let _ = fs::remove_file(PID_PATH);
    eprintln!("[helper] cleaned up, exiting");
    std::process::exit(0);
}

fn write_pid_file() -> bool {
    let my_pid = std::process::id();

    // Check for existing PID file
    if let Ok(contents) = fs::read_to_string(PID_PATH) {
        if let Ok(old_pid) = contents.trim().parse::<u32>() {
            // Check if that process is still alive
            let alive = unsafe { libc::kill(old_pid as i32, 0) == 0 };
            if alive && old_pid != my_pid {
                eprintln!("[helper] another instance already running (pid {})", old_pid);
                return false;
            }
        }
    }

    if let Err(e) = fs::write(PID_PATH, format!("{}", my_pid)) {
        eprintln!("[helper] failed to write PID file: {}", e);
        return false;
    }
    true
}

/// Start observing NSWorkspace notifications for app hide/unhide.
/// Runs on a background thread with its own run loop.

fn main() {
    // Single-instance guard
    if !write_pid_file() {
        eprintln!("[helper] exiting to avoid duplicate instance");
        std::process::exit(1);
    }

    let _ = fs::remove_file(SOCKET_PATH);
    eprintln!("aerospace-helper v0.7 starting (pid {})", std::process::id());

    // Register signal handlers for cleanup
    unsafe {
        libc::signal(libc::SIGTERM, cleanup_and_exit as *const () as usize);
        libc::signal(libc::SIGINT, cleanup_and_exit as *const () as usize);
    }

    let state = Arc::new(Mutex::new(HelperState::new()));
    update_borders(&state);

    // File watcher thread for config hot-reload
    let state_watcher = Arc::clone(&state);
    thread::spawn(move || {
        let (tx, rx) = std::sync::mpsc::channel();
        let mut watcher = notify::recommended_watcher(move |res: Result<Event, _>| {
            if let Ok(event) = res { let _ = tx.send(event); }
        }).expect("Failed to create file watcher");

        watcher.watch(Path::new(CONFIG_PATH), RecursiveMode::NonRecursive).ok();
        watcher.watch(Path::new(ICON_MAP_PATH), RecursiveMode::NonRecursive).ok();
        eprintln!("[helper] file watcher started");

        let mut last_reload = Instant::now();
        loop {
            match rx.recv_timeout(Duration::from_secs(5)) {
                Ok(event) => {
                    if !matches!(event.kind, EventKind::Modify(_) | EventKind::Create(_)) { continue; }
                    if Instant::now().duration_since(last_reload) < Duration::from_millis(500) { continue; }
                    thread::sleep(Duration::from_millis(500));
                    while rx.try_recv().is_ok() {} // Drain
                    last_reload = Instant::now();

                    let mut s = state_watcher.lock().unwrap();
                    for path in &event.paths {
                        let p = path.to_str().unwrap_or("");
                        if p.contains("aerospace.toml") {
                            s.floating_app_patterns = load_floating_patterns();
                            eprintln!("[helper] reloaded {} floating patterns", s.floating_app_patterns.len());
                        }
                        if p.contains("icon_map.toml") {
                            s.icon_map = load_icon_map();
                            eprintln!("[helper] reloaded {} icon mappings", s.icon_map.len());
                        }
                    }
                }
                Err(std::sync::mpsc::RecvTimeoutError::Timeout) => continue,
                Err(_) => break,
            }
        }
    });

    // Workspace worker thread — processes workspace_changed events sequentially
    // to avoid concurrent aerospace_cmd calls (AeroSpace is single-threaded and deadlocks)
    let (ws_tx, ws_rx) = mpsc::channel::<String>();
    let state_ws_worker = Arc::clone(&state);
    thread::spawn(move || {
        for workspace in ws_rx {
            if workspace == "__visibility__" {
                // App visibility changed — find G9 workspace and re-evaluate
                eprintln!("[helper] ws-worker: app visibility changed");
                let monitors = aerospace_cmd(&["list-monitors", "--format", "%{monitor-id}|%{monitor-name}"]).unwrap_or_default();
                let g9_mid = monitors.lines()
                    .find(|l| l.contains(G9_PATTERN))
                    .and_then(|l| l.split('|').next())
                    .unwrap_or("")
                    .to_string();
                let g9_ws = if !g9_mid.is_empty() {
                    aerospace_cmd(&["list-workspaces", "--monitor", &g9_mid, "--visible"])
                        .unwrap_or_default().trim().to_string()
                } else {
                    String::new()
                };
                if !g9_ws.is_empty() {
                    eprintln!("[helper] ws-worker: re-evaluating G9 ws{}", g9_ws);
                    let prev_gaps = {
                        let s = state_ws_worker.lock().unwrap();
                        s.gap_state.clone()
                    };
                    update_sketchybar(&g9_ws, &state_ws_worker);
                    handle_gaps(&g9_ws, &state_ws_worker);
                    let needs_retile = {
                        let s = state_ws_worker.lock().unwrap();
                        s.gap_state != prev_gaps
                    };
                    if needs_retile {
                        std::thread::sleep(Duration::from_millis(500));
                        retile_all_visible(&g9_ws, &state_ws_worker);
                    }
                }
            } else {
                eprintln!("[helper] ws-worker processing workspace={}", workspace);
                // Borders + gaps first (fast, visible to user), sketchybar last (slow, decorative)
                update_borders(&state_ws_worker);
                handle_gaps(&workspace, &state_ws_worker);
                update_sketchybar(&workspace, &state_ws_worker);
            }
        }
    });

    // Socket listener on a background thread
    let state_socket = Arc::clone(&state);
    thread::spawn(move || {
        let listener = UnixListener::bind(SOCKET_PATH).expect("Failed to bind socket");
        eprintln!("[helper] socket listener ready on {}", SOCKET_PATH);

        for stream in listener.incoming() {
            if SHUTDOWN.load(Ordering::Relaxed) { break; }
            match stream {
                Ok(stream) => {
                    let state = Arc::clone(&state_socket);
                    let ws_tx = ws_tx.clone();
                    thread::spawn(move || handle_client(stream, state, ws_tx));
                }
                Err(e) => eprintln!("Connection error: {}", e),
            }
        }
    });

    // Give socket a moment to bind
    thread::sleep(Duration::from_millis(100));

    // Main thread: register workspace notifications and run NSRunLoop
    // NSWorkspace notifications require the main thread's run loop
    let workspace = NSWorkspace::sharedWorkspace();
    let center = workspace.notificationCenter();

    let hide_block = RcBlock::new(|_notif: NonNull<NSNotification>| {
        eprintln!("[helper] NSWorkspace: app hidden");
        send_self_event("app_visibility_changed");
    });

    let unhide_block = RcBlock::new(|_notif: NonNull<NSNotification>| {
        eprintln!("[helper] NSWorkspace: app unhidden");
        send_self_event("app_visibility_changed");
    });

    let terminate_block = RcBlock::new(|_notif: NonNull<NSNotification>| {
        eprintln!("[helper] NSWorkspace: app terminated");
        send_self_event("app_visibility_changed");
    });

    let launch_block = RcBlock::new(|_notif: NonNull<NSNotification>| {
        eprintln!("[helper] NSWorkspace: app launched");
        send_self_event("app_visibility_changed");
    });

    let hide_name = objc2_foundation::NSNotificationName::from_str("NSWorkspaceDidHideApplicationNotification");
    let unhide_name = objc2_foundation::NSNotificationName::from_str("NSWorkspaceDidUnhideApplicationNotification");
    let terminate_name = objc2_foundation::NSNotificationName::from_str("NSWorkspaceDidTerminateApplicationNotification");
    let launch_name = objc2_foundation::NSNotificationName::from_str("NSWorkspaceDidLaunchApplicationNotification");

    unsafe {
        center.addObserverForName_object_queue_usingBlock(
            Some(&hide_name), None, None, &hide_block,
        );
        center.addObserverForName_object_queue_usingBlock(
            Some(&unhide_name), None, None, &unhide_block,
        );
        center.addObserverForName_object_queue_usingBlock(
            Some(&terminate_name), None, None, &terminate_block,
        );
        center.addObserverForName_object_queue_usingBlock(
            Some(&launch_name), None, None, &launch_block,
        );
    }

    eprintln!("[helper] workspace observer registered on main thread");

    // Run the main thread's run loop forever to receive notifications
    loop {
        if SHUTDOWN.load(Ordering::Relaxed) {
            cleanup_and_exit();
        }
        objc2_foundation::NSRunLoop::currentRunLoop()
            .runUntilDate(&objc2_foundation::NSDate::dateWithTimeIntervalSinceNow(1.0));
    }
}
