use std::collections::HashMap;
use std::fs;
use std::io::{BufRead, BufReader};
use std::os::unix::net::{UnixListener, UnixStream};
use std::process::Command;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

use objc2_app_kit::NSWorkspace;

const SOCKET_PATH: &str = "/tmp/aerospace-helper.sock";
const G9_PATTERN: &str = "Odyssey";
const CONFIG_PATH: &str = "/Users/eric/.config/aerospace/aerospace.toml";

// Gap values
const GAP_NORMAL: &str = "15";
const GAP_CENTERED: &str = "1280";

const ALWAYS_FLOATING: &[&str] = &[
    "com.mantle.app",
    "com.1password.1password",
    "com.microsoft.teams2",
    "com.wispr.flow",
    "com.logi.cp-dev-mgr.common",
    "com.apple.ScreenMirroring",
    "com.anthropic.claudefordesktop",
    "com.cisco.secureclient.gui",
    "com.elgato.StreamDeck",
    "us.zoom.xos",
    "meetily",
];

#[derive(Debug, Clone, PartialEq)]
enum GapState {
    Normal,
    Centered,
}

struct HelperState {
    gap_state: GapState,
    last_reload: Instant,
}

impl HelperState {
    fn new() -> Self {
        Self {
            gap_state: GapState::Normal,
            last_reload: Instant::now() - Duration::from_secs(10),
        }
    }
}

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

fn count_visible_windows(workspace: &str) -> usize {
    let hidden = get_hidden_bundle_ids();
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{app-bundle-id}",
    ]).unwrap_or_default();

    output.lines().filter(|line| {
        let bid = line.trim();
        !bid.is_empty()
            && !hidden.contains(&bid.to_string())
            && !ALWAYS_FLOATING.contains(&bid)
    }).count()
}

fn float_hidden_windows(workspace: &str) {
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

fn set_gaps(target: &GapState, state: &mut HelperState) {
    if *target == state.gap_state {
        return; // Already in the right state
    }

    let gap_value = match target {
        GapState::Centered => GAP_CENTERED,
        GapState::Normal => GAP_NORMAL,
    };

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
    state.gap_state = target.clone();
    state.last_reload = Instant::now();
}

// --- Event handling ---

fn update_borders() {
    let _ = Command::new("/bin/bash")
        .arg("-c")
        .arg("source $HOME/.config/colorscheme.sh; /opt/homebrew/bin/borders active_color=\"glow(0xff${COLOR_LAVENDER})\" inactive_color=\"0xff${COLOR_BG}\"")
        .spawn();
}

fn trigger_sketchybar(workspace: &str) {
    let _ = Command::new("/opt/homebrew/bin/sketchybar")
        .args(["--trigger", "aerospace_workspace_change",
               &format!("FOCUSED_WORKSPACE={}", workspace)])
        .spawn();
}

fn handle_gaps(workspace: &str, state: &mut HelperState) {
    if !is_on_g9(workspace) {
        // Not on G9 — ensure normal gaps
        set_gaps(&GapState::Normal, state);
        return;
    }

    float_hidden_windows(workspace);
    let count = count_visible_windows(workspace);

    eprintln!("[helper] ws{}: {} visible windows, gaps={:?}", workspace, count, state.gap_state);

    if count <= 1 {
        set_gaps(&GapState::Centered, state);
    } else {
        set_gaps(&GapState::Normal, state);
    }
}

fn handle_event(raw_event: &str, state: &mut HelperState) {
    let (event, workspace) = if let Some((ev, ws)) = raw_event.split_once(':') {
        (ev.to_string(), ws.to_string())
    } else {
        let ws = match aerospace_cmd(&["list-workspaces", "--focused"]) {
            Some(ws) => ws,
            None => return,
        };
        (raw_event.to_string(), ws)
    };

    eprintln!("[helper] event={} workspace={}", event, workspace);

    match event.as_str() {
        "workspace_changed" => {
            trigger_sketchybar(&workspace);
            update_borders();
            handle_gaps(&workspace, state);
        }
        "focus_changed" => {
            update_borders();
            // Check if window count changed (new window opened/closed)
            handle_gaps(&workspace, state);
        }
        _ => {}
    }
}

fn handle_client(stream: UnixStream, state: Arc<Mutex<HelperState>>) {
    let reader = BufReader::new(stream);
    for line in reader.lines() {
        if let Ok(event) = line {
            let event = event.trim().to_string();
            if event.is_empty() { continue; }
            let mut s = state.lock().unwrap();
            handle_event(&event, &mut s);
        }
    }
}

fn main() {
    let _ = fs::remove_file(SOCKET_PATH);
    let listener = UnixListener::bind(SOCKET_PATH).expect("Failed to bind socket");
    eprintln!("aerospace-helper v0.4 listening on {}", SOCKET_PATH);

    let state = Arc::new(Mutex::new(HelperState::new()));
    update_borders();

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                let state = Arc::clone(&state);
                thread::spawn(move || handle_client(stream, state));
            }
            Err(e) => eprintln!("Connection error: {}", e),
        }
    }
}
