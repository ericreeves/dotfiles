use std::collections::HashMap;
use std::ffi::c_void;
use std::fs;
use std::io::{BufRead, BufReader};
use std::os::unix::net::{UnixListener, UnixStream};
use std::process::Command;
use std::ptr::NonNull;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

use objc2_app_kit::NSWorkspace;
use objc2_application_services::{AXUIElement, AXValue, AXValueType};
use objc2_core_foundation::{CFString, CFType, CGPoint, CGSize};

const SOCKET_PATH: &str = "/tmp/aerospace-helper.sock";
const G9_PATTERN: &str = "Odyssey";
const G9_WIDTH: f64 = 5120.0;
const CENTER_W: f64 = 2560.0;
const TOP_Y: f64 = 50.0;
const BOTTOM_PAD: f64 = 15.0;

const AX_POSITION: &str = "AXPosition";
const AX_SIZE: &str = "AXSize";
const AX_WINDOWS: &str = "AXWindows";

// Apps that are always floating and should be excluded from visible window count
// These are apps listed in aerospace's [[on-window-detected]] floating rules
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

#[derive(Debug, Clone)]
enum WorkspaceState {
    Centered(String),
    Tiled,
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
    let output = Command::new("/opt/homebrew/bin/aerospace").args(args).output().ok()?;
    if output.status.success() {
        Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
    } else {
        None
    }
}

fn get_focused_workspace() -> Option<String> {
    aerospace_cmd(&["list-workspaces", "--focused"])
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

struct WindowInfo {
    wid: String,
    #[allow(dead_code)]
    app_name: String,
    bundle_id: String,
    pid: Option<i32>,
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

fn get_pid_for_bundle_id(bundle_id: &str) -> Option<i32> {
    let workspace = NSWorkspace::sharedWorkspace();
    let apps = workspace.runningApplications();
    for app in apps.iter() {
        if let Some(bid) = app.bundleIdentifier() {
            if bid.to_string() == bundle_id {
                return Some(app.processIdentifier());
            }
        }
    }
    None
}

/// Float any hidden app windows on a workspace so they don't consume tiling space
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
        let wid = parts[0].trim();
        let bid = parts[1];
        if hidden.contains(&bid.to_string()) {
            eprintln!("[helper] floating hidden window {} ({})", wid, bid);
            let _ = aerospace_cmd(&["layout", "--window-id", wid, "floating"]);
        }
    }
}

fn get_visible_windows(workspace: &str) -> Vec<WindowInfo> {
    let hidden = get_hidden_bundle_ids();
    let output = aerospace_cmd(&[
        "list-windows", "--workspace", workspace,
        "--format", "%{window-id}|%{app-name}|%{app-bundle-id}",
    ]).unwrap_or_default();

    output.lines().filter_map(|line| {
        let parts: Vec<&str> = line.split('|').collect();
        if parts.len() != 3 { return None; }
        let wid = parts[0].trim().to_string();
        let app_name = parts[1].to_string();
        let bundle_id = parts[2].to_string();
        if wid.is_empty() { return None; }
        if hidden.contains(&bundle_id) { return None; }
        if ALWAYS_FLOATING.contains(&bundle_id.as_str()) { return None; }
        let pid = get_pid_for_bundle_id(&bundle_id);
        Some(WindowInfo { wid, app_name, bundle_id, pid })
    }).collect()
}

// --- Native Accessibility API for window positioning ---

// Raw CFArray access since the typed API requires specific Type bounds
unsafe extern "C" {
    fn CFArrayGetCount(array: *const c_void) -> isize;
    fn CFArrayGetValueAtIndex(array: *const c_void, idx: isize) -> *const c_void;
}

fn get_first_window(pid: i32) -> Option<*const c_void> {
    unsafe {
        let app = AXUIElement::new_application(pid);
        let attr = CFString::from_static_str(AX_WINDOWS);
        let mut value: *const CFType = std::ptr::null();

        let err = app.copy_attribute_value(&attr, NonNull::from_mut(&mut value));
        if err.0 != 0 || value.is_null() {
            return None;
        }

        let array = value as *const c_void;
        let count = CFArrayGetCount(array);
        if count == 0 {
            return None;
        }

        let window = CFArrayGetValueAtIndex(array, 0);
        if window.is_null() {
            return None;
        }

        Some(window)
    }
}

fn set_window_position_native(pid: i32, x: f64, y: f64) -> bool {
    unsafe {
        let window_ptr = match get_first_window(pid) {
            Some(p) => p,
            None => return false,
        };
        let window = &*(window_ptr as *const AXUIElement);

        let mut point = CGPoint { x, y };
        let point_ptr = NonNull::from_mut(&mut point).cast::<c_void>();
        if let Some(ax_val) = AXValue::new(AXValueType::CGPoint, point_ptr) {
            let attr = CFString::from_static_str(AX_POSITION);
            let err = window.set_attribute_value(&attr, &ax_val);
            return err.0 == 0;
        }
        false
    }
}

fn set_window_size_native(pid: i32, w: f64, h: f64) -> bool {
    unsafe {
        let window_ptr = match get_first_window(pid) {
            Some(p) => p,
            None => return false,
        };
        let window = &*(window_ptr as *const AXUIElement);

        let mut size = CGSize { width: w, height: h };
        let size_ptr = NonNull::from_mut(&mut size).cast::<c_void>();
        if let Some(ax_val) = AXValue::new(AXValueType::CGSize, size_ptr) {
            let attr = CFString::from_static_str(AX_SIZE);
            let err = window.set_attribute_value(&attr, &ax_val);
            return err.0 == 0;
        }
        false
    }
}

fn get_window_x(pid: i32) -> Option<f64> {
    unsafe {
        let window_ptr = get_first_window(pid)?;
        let window = &*(window_ptr as *const AXUIElement);

        let attr = CFString::from_static_str(AX_POSITION);
        let mut value: *const CFType = std::ptr::null();
        let err = window.copy_attribute_value(&attr, NonNull::from_mut(&mut value));
        if err.0 != 0 || value.is_null() {
            return None;
        }

        let mut point = CGPoint { x: 0.0, y: 0.0 };
        AXValue::value(
            &*(value as *const AXValue),
            AXValueType::CGPoint,
            NonNull::from_mut(&mut point).cast::<c_void>(),
        );
        Some(point.x)
    }
}

// --- Window management logic ---

fn center_window(win: &WindowInfo) -> bool {
    let pid = match win.pid {
        Some(p) => p,
        None => return false,
    };

    let _ = aerospace_cmd(&["layout", "--window-id", &win.wid, "tiling"]);
    let _ = aerospace_cmd(&["layout", "--window-id", &win.wid, "floating"]);

    // Wait for aerospace to finish its layout pass after the tiling→floating transition
    std::thread::sleep(Duration::from_millis(100));

    let h = 1440.0 - TOP_Y - BOTTOM_PAD;
    let x = (G9_WIDTH - CENTER_W) / 2.0;

    // Set size first, then retry position — aerospace may override briefly after floating
    set_window_size_native(pid, CENTER_W, h);

    let mut positioned = false;
    for attempt in 0..5 {
        set_window_position_native(pid, x, TOP_Y);
        if let Some(actual_x) = get_window_x(pid) {
            if (actual_x - x).abs() < 5.0 {
                eprintln!("[helper] centered on attempt {}", attempt + 1);
                positioned = true;
                break;
            }
            eprintln!("[helper] attempt {}: actual_x={} expected={}", attempt + 1, actual_x, x);
        }
        std::thread::sleep(Duration::from_millis(30));
    }

    if positioned {
        return true;
    }

    eprintln!("[helper] centering FAILED after 5 attempts, retiling");
    let _ = aerospace_cmd(&["layout", "--window-id", &win.wid, "tiling"]);
    false
}

fn retile_window(wid: &str) {
    let _ = aerospace_cmd(&["layout", "--window-id", wid, "tiling"]);
}

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

fn handle_event(event: &str, state: &mut HelperState) {
    let workspace = match get_focused_workspace() {
        Some(ws) => ws,
        None => { eprintln!("[helper] no focused workspace"); return; },
    };

    let now = Instant::now();
    if event == "focus_changed" && now.duration_since(state.last_event) < Duration::from_millis(50) {
        eprintln!("[helper] debounced focus_changed for ws{}", workspace);
        return;
    }
    state.last_event = now;

    eprintln!("[helper] event={} workspace={}", event, workspace);

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
        eprintln!("[helper] ws{} not on G9, skipping", workspace);
        return;
    }

    // Float hidden windows so they don't consume tiling space
    float_hidden_windows(workspace);

    let windows = get_visible_windows(workspace);
    let prev = state.workspaces.get(workspace).cloned().unwrap_or(WorkspaceState::Empty);

    eprintln!("[helper] ws{}: {} visible windows, prev={:?}", workspace, windows.len(), prev);

    match windows.len() {
        1 => {
            let win = &windows[0];
            eprintln!("[helper] single window: wid={} app={} pid={:?}", win.wid, win.app_name, win.pid);
            if let WorkspaceState::Centered(ref prev_wid) = prev {
                if prev_wid == &win.wid {
                    // Verify the window is actually still at the centered position
                    // (user may have manually retiled it via service mode)
                    if let Some(pid) = win.pid {
                        let expected_x = (G9_WIDTH - CENTER_W) / 2.0;
                        if let Some(actual_x) = get_window_x(pid) {
                            if (actual_x - expected_x).abs() < 5.0 {
                                eprintln!("[helper] already centered, verified");
                                return;
                            }
                            eprintln!("[helper] state=centered but window at x={}, re-centering", actual_x);
                        }
                    } else {
                        eprintln!("[helper] already centered, skip (no pid to verify)");
                        return;
                    }
                }
            }
            eprintln!("[helper] centering window {}", win.wid);
            if center_window(win) {
                state.workspaces.insert(workspace.to_string(), WorkspaceState::Centered(win.wid.clone()));
            } else {
                state.workspaces.insert(workspace.to_string(), WorkspaceState::Tiled);
            }
        }
        n if n >= 2 => {
            if let WorkspaceState::Centered(ref auto_wid) = prev {
                retile_window(auto_wid);
                for win in &windows {
                    if win.wid != *auto_wid {
                        retile_window(&win.wid);
                    }
                }
            }
            state.workspaces.insert(workspace.to_string(), WorkspaceState::Tiled);
        }
        _ => { state.workspaces.remove(workspace); }
    }
}

fn handle_retile(workspace: &str, state: &mut HelperState) {
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
        for ws in to_remove { state.workspaces.remove(&ws); }
        return;
    }

    // Float hidden windows before counting
    float_hidden_windows(workspace);

    let visible = get_visible_windows(workspace);
    let count = visible.len();
    let prev = state.workspaces.get(workspace).cloned().unwrap_or(WorkspaceState::Empty);

    eprintln!("[helper] retile: ws{} count={} prev={:?}", workspace, count, prev);

    if count >= 2 {
        if matches!(prev, WorkspaceState::Centered(_)) {
            for win in &visible {
                retile_window(&win.wid);
            }
            state.workspaces.insert(workspace.to_string(), WorkspaceState::Tiled);
        }
    } else if count == 1 {
        if !matches!(prev, WorkspaceState::Centered(_)) {
            handle_dynamic_gaps(workspace, state);
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
    let _ = fs::remove_file(SOCKET_PATH);
    let listener = UnixListener::bind(SOCKET_PATH).expect("Failed to bind socket");
    eprintln!("aerospace-helper v0.2 listening on {}", SOCKET_PATH);

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
