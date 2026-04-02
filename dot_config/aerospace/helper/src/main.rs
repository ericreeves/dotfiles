use std::collections::HashMap;
use std::fs;
use std::io::{BufRead, BufReader};
use std::os::unix::net::{UnixListener, UnixStream};
use std::process::Command;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

const SOCKET_PATH: &str = "/tmp/aerospace-helper.sock";
const G9_PATTERN: &str = "Odyssey";
const G9_WIDTH: i32 = 5120;
const CENTER_W: i32 = 2560;
const TOP_Y: i32 = 50;
const BOTTOM_PAD: i32 = 15;

#[derive(Debug, Clone)]
enum WorkspaceState {
    Centered(String), // window ID
    Tiled(usize),     // window count
    Empty,
}

struct HelperState {
    workspaces: HashMap<String, WorkspaceState>,
    last_event: Instant,
}

impl HelperState {
    fn new() -> Self {
        Self {
            workspaces: HashMap::new(),
            last_event: Instant::now(),
        }
    }
}

fn aerospace_cmd(args: &[&str]) -> Option<String> {
    let output = Command::new("aerospace")
        .args(args)
        .output()
        .ok()?;
    if output.status.success() {
        Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
    } else {
        None
    }
}

fn get_focused_workspace() -> Option<String> {
    aerospace_cmd(&["list-workspaces", "--focused"])
}

fn get_monitor_for_workspace(workspace: &str) -> Option<String> {
    // Try getting monitor from windows on the workspace
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{monitor-name}",
    ])?;

    if let Some(first_line) = output.lines().next() {
        if !first_line.is_empty() {
            return Some(first_line.to_string());
        }
    }

    // Fallback: check workspace-to-monitor mapping
    let monitors = aerospace_cmd(&["list-monitors", "--format", "%{monitor-id}|%{monitor-name}"])?;
    for line in monitors.lines() {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 2 { continue; }
        let mid = parts[0];
        let mname = parts[1];
        let workspaces = aerospace_cmd(&[
            "list-workspaces", "--monitor", mid, "--format", "%{workspace}",
        ]).unwrap_or_default();
        if workspaces.lines().any(|ws| ws == workspace) {
            return Some(mname.to_string());
        }
    }
    None
}

fn is_on_g9(workspace: &str) -> bool {
    get_monitor_for_workspace(workspace)
        .map(|m| m.contains(G9_PATTERN))
        .unwrap_or(false)
}

fn get_hidden_bundle_ids() -> Vec<String> {
    let output = Command::new("osascript")
        .arg("-e")
        .arg(r#"
tell application "System Events"
  set output to ""
  repeat with p in (every application process whose background only is false and visible is false)
    set output to output & bundle identifier of p & linefeed
  end repeat
  return output
end tell"#)
        .output()
        .ok();

    match output {
        Some(o) if o.status.success() => {
            String::from_utf8_lossy(&o.stdout)
                .lines()
                .filter(|l| !l.is_empty())
                .map(|l| l.to_string())
                .collect()
        }
        _ => vec![],
    }
}

/// Returns (window_id, app_name, bundle_id) for visible windows on a workspace
fn get_visible_windows(workspace: &str) -> Vec<(String, String, String)> {
    let hidden = get_hidden_bundle_ids();

    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{window-id}|%{app-name}|%{app-bundle-id}",
    ]).unwrap_or_default();

    output.lines()
        .filter_map(|line| {
            let parts: Vec<&str> = line.split('|').collect();
            if parts.len() != 3 { return None; }
            let wid = parts[0].trim().to_string();
            let app = parts[1].to_string();
            let bid = parts[2].to_string();
            if wid.is_empty() { return None; }
            if hidden.contains(&bid) { return None; }
            Some((wid, app, bid))
        })
        .collect()
}

fn center_window(wid: &str, app_name: &str) -> bool {
    // Tile first to reset floating position, then float
    let _ = aerospace_cmd(&["layout", "--window-id", wid, "tiling"]);
    let _ = aerospace_cmd(&["layout", "--window-id", wid, "floating"]);

    let h = 1440 - TOP_Y - BOTTOM_PAD;
    let x = (G9_WIDTH - CENTER_W) / 2;

    let script = format!(
        r#"tell application "System Events"
    tell application process "{}"
        set position of front window to {{{}, {}}}
        set size of front window to {{{}, {}}}
    end tell
end tell"#,
        app_name, x, TOP_Y, CENTER_W, h
    );

    let result = Command::new("osascript")
        .arg("-e")
        .arg(&script)
        .output();

    if result.is_err() {
        return false;
    }

    // Verify position
    let verify_script = format!(
        r#"tell application "System Events" to tell application process "{}" to get item 1 of (get position of front window)"#,
        app_name
    );

    let verify = Command::new("osascript")
        .arg("-e")
        .arg(&verify_script)
        .output()
        .ok();

    match verify {
        Some(o) if o.status.success() => {
            let actual_x = String::from_utf8_lossy(&o.stdout).trim().to_string();
            if actual_x == x.to_string() {
                true
            } else {
                // Position failed — retile
                let _ = aerospace_cmd(&["layout", "--window-id", wid, "tiling"]);
                false
            }
        }
        _ => {
            let _ = aerospace_cmd(&["layout", "--window-id", wid, "tiling"]);
            false
        }
    }
}

fn retile_window(wid: &str) {
    let _ = aerospace_cmd(&["layout", "--window-id", wid, "tiling"]);
}

fn update_borders() {
    let _ = Command::new("bash")
        .arg("-c")
        .arg("source $HOME/.config/colorscheme.sh; borders active_color=\"glow(0xff${COLOR_LAVENDER})\" inactive_color=\"0xff${COLOR_BG}\"")
        .spawn();
}

fn trigger_sketchybar(workspace: &str) {
    let _ = Command::new("sketchybar")
        .args(["--trigger", "aerospace_workspace_change",
               &format!("FOCUSED_WORKSPACE={}", workspace)])
        .spawn();
}

fn handle_event(event: &str, state: &mut HelperState) {
    let workspace = match get_focused_workspace() {
        Some(ws) => ws,
        None => return,
    };

    // Debounce: ignore events within 50ms of each other
    let now = Instant::now();
    if now.duration_since(state.last_event) < Duration::from_millis(50) && event == "focus_changed" {
        return;
    }
    state.last_event = now;

    match event {
        "workspace_changed" => {
            trigger_sketchybar(&workspace);
            update_borders();
            handle_dynamic_gaps(&workspace, state);
        }
        "focus_changed" => {
            update_borders();
            handle_retile(&workspace, state);
        }
        _ => {}
    }
}

fn handle_dynamic_gaps(workspace: &str, state: &mut HelperState) {
    if !is_on_g9(workspace) {
        return;
    }

    let windows = get_visible_windows(workspace);
    let prev = state.workspaces.get(workspace).cloned().unwrap_or(WorkspaceState::Empty);

    match windows.len() {
        1 => {
            let (ref wid, ref app, _) = windows[0];
            // Already centered with same window — skip
            if let WorkspaceState::Centered(ref prev_wid) = prev {
                if prev_wid == wid {
                    return;
                }
            }
            if center_window(wid, app) {
                state.workspaces.insert(workspace.to_string(), WorkspaceState::Centered(wid.clone()));
            } else {
                state.workspaces.insert(workspace.to_string(), WorkspaceState::Tiled(1));
            }
        }
        n if n >= 2 => {
            if let WorkspaceState::Centered(ref auto_wid) = prev {
                // Only retile the auto-centered window
                retile_window(auto_wid);
                for (wid, _, _) in &windows {
                    if wid != auto_wid {
                        retile_window(wid);
                    }
                }
            }
            state.workspaces.insert(workspace.to_string(), WorkspaceState::Tiled(n));
        }
        _ => {
            state.workspaces.remove(workspace);
        }
    }
}

fn handle_retile(workspace: &str, state: &mut HelperState) {
    // On non-G9: retile any auto-centered windows that moved here
    if !is_on_g9(workspace) {
        let windows = aerospace_cmd(&[
            "list-windows", "--workspace", workspace, "--format", "%{window-id}",
        ]).unwrap_or_default();

        let mut to_remove = vec![];
        for (ws, ws_state) in state.workspaces.iter() {
            if let WorkspaceState::Centered(auto_wid) = ws_state {
                if windows.lines().any(|w| w.trim() == auto_wid.as_str()) {
                    retile_window(auto_wid);
                    to_remove.push(ws.clone());
                }
            }
        }
        for ws in to_remove {
            state.workspaces.remove(&ws);
        }
        return;
    }

    let count_str = aerospace_cmd(&[
        "list-windows", "--workspace", workspace, "--count",
    ]).unwrap_or_default();
    let count: usize = count_str.parse().unwrap_or(0);
    let prev = state.workspaces.get(workspace).cloned().unwrap_or(WorkspaceState::Empty);

    if count >= 2 {
        if let WorkspaceState::Centered(ref auto_wid) = prev {
            let windows = aerospace_cmd(&[
                "list-windows", "--workspace", workspace, "--format", "%{window-id}",
            ]).unwrap_or_default();
            for wid in windows.lines() {
                let wid = wid.trim();
                if !wid.is_empty() {
                    retile_window(wid);
                }
            }
            let _ = auto_wid; // used above via prev match
            state.workspaces.insert(workspace.to_string(), WorkspaceState::Tiled(count));
        }
    } else if count == 1 {
        match prev {
            WorkspaceState::Centered(_) => {} // already centered
            _ => handle_dynamic_gaps(workspace, state),
        }
    } else {
        state.workspaces.remove(workspace);
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
    // Clean up old socket
    let _ = fs::remove_file(SOCKET_PATH);

    let listener = UnixListener::bind(SOCKET_PATH).expect("Failed to bind socket");
    eprintln!("aerospace-helper listening on {}", SOCKET_PATH);

    let state = Arc::new(Mutex::new(HelperState::new()));

    // Initial border update
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
