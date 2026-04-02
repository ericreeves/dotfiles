This is a macOS environment (MacBook Pro with Apple Silicon).

## Dotfiles Management (chezmoi)

All files under `~/.config/` are managed by [chezmoi](https://www.chezmoi.io/). Source: `~/.local/share/chezmoi/`, remote: `github.com/ericreeves/dotfiles`.

**After editing any config file, always run `chezmoi add <file>` to sync the change to the chezmoi source.** Chezmoi auto-commits and pushes on `add`.

**When pulling:** Use `chezmoi diff` before `chezmoi apply` to review incoming changes. Never blindly apply — show the user any diffs for files unrelated to the current task and let them decide. Only apply changes related to the active work.

## Display Configuration

- **Primary monitor:** Samsung Odyssey G95SC (G9 ultrawide) — 5120x1440 @ 240Hz, no scaling
- **Secondary monitor:** Built-in MacBook Pro display — 3024x1964 Retina
- Used in three configurations: G9 only, MacBook only, or both together
- When both connected: AeroSpace workspaces 1-5 on G9 (main), 6-9 on MBP (secondary)
- On the G9, single windows should be centered at 2560px wide (half the ultrawide) — full 5120px is too wide for one app
- The macOS menu bar is ~25px — tiled windows start at Y=40 on the G9 (menu bar + 15px padding)

## Config Organization Pattern

Configs are grouped by **WM stack** — the tiling WM folder contains all related tool configs, not one folder per tool. This way adding/removing a WM stack is a single directory operation. Tools are pointed to their configs via `--config` flags or env vars in startup commands (no symlinks).

## Window Management Stack (macOS — active)

All configs live under `~/.config/aerospace/` (the stack folder):
- **AeroSpace** — tiling window manager (`~/.config/aerospace/aerospace.toml`)
- **AeroSpaceBar** — menu bar workspace indicator (`~/.config/aerospacebar/aerospacebar.toml` — lives outside the stack folder because the app auto-saves settings to its XDG path; settings also accessible via Cmd+,)
- **JankyBorders** — window borders (`~/.config/aerospace/borders/bordersrc`) — sourced directly as bash script
- **Scripts** — `~/.config/aerospace/scripts/` (dynamic_gaps.sh, border_update.sh, window_position.sh, etc.)
- **Management script:** `~/.local/bin/aero` (start/stop/restart/status)
- Theme: Catppuccin Mocha with Lavender accent
- Central colorscheme: `~/.config/colorscheme.sh`
- **Border colors by window state** (Catppuccin Mocha palette):
  - Lavender `#b4befe` (glow) — normal tiling
  - Blue `#89b4fa` — accordion/stacked
  - Green `#a6e3a1` — fullscreen
  - Mauve `#cba6f7` — floating
  - Inactive: Crust `#11111b`

### AeroSpace Behavioral Notes

- **Single-window centering on the G9** is achieved by editing `outer.left`/`outer.right` gaps in `aerospace.toml` via the Rust helper, then calling `aerospace reload-config`. Windows stay tiled — no floating, no AX API positioning. This is the community-proven approach from [issue #60](https://github.com/nikitabobko/AeroSpace/issues/60). See [`AEROSPACE-ULTRAWIDE-FORK.md`](~/.config/aerospace/AEROSPACE-ULTRAWIDE-FORK.md) for a plan to replace this with a native solution via cherry-picking [PR #1512](https://github.com/nikitabobko/AeroSpace/pull/1512).
- **Per-monitor gap syntax** is critical: `outer.left = [{ monitor.'main' = 1280 }, 15]` applies 1280 only to the main monitor, 15 to all others. Without this, large gaps apply to the MBP too.
- **`exec-on-workspace-change`** must pass workspace in the event: `aero-notify "workspace_changed:$AEROSPACE_FOCUSED_WORKSPACE"`. Querying `aerospace list-workspaces --focused` from the helper is racy.
- **All binaries in aerospace.toml callbacks must use absolute paths** — aerospace's exec environment has a minimal PATH.
- **Rust helper** (`~/.config/aerospace/helper/`) handles centering, sketchybar, borders. Listens on Unix socket `/tmp/aerospace-helper.sock`.

### What doesn't work for window centering (tried and failed)

- **Floating + AX API positioning** — aerospace overrides floating window positions after callbacks return. Retry loops, delayed re-application, stability checks all fail because aerospace actively manages floating windows.
- **`aerospace enable off/on`** — breaks sketchybar rendering.
- **`aerospace resize width` on single tiled windows** — no-op (nothing to split against).
- **osascript positioning** — slow, racy, targets wrong window when app has multiple windows across displays.
- **Blocking sleeps in event handlers** — blocks processing of subsequent events, causes stale state.

### What works

- **`sed` + `aerospace reload-config`** — edit outer gaps in the TOML and reload. Windows stay tiled, aerospace handles all positioning. Brief visual flash during reload but 100% reliable.
- **Hidden windows** take tiling space. Must float them (`layout floating`) AND exclude from visible window count via `ALWAYS_FLOATING` bundle ID list in the helper.
- **Native `NSWorkspace` API** (via objc2-app-kit) to detect hidden apps — faster and more reliable than osascript.

### Required Test Cases (all must pass)

1. **T1: Center single window** — switch to G9 workspace with 1 window → centered at x≈1280
2. **T2: Switch workspaces** — ws2→ws1 → window stays centered
3. **T3: Rapid switching** — ws2→ws3→ws1 quickly → window centered on ws1
4. **T4: Add window** — move second window to workspace → both tile at full width (x≈15, x≈2567)
5. **T5: Remove window** — remove second window → remaining window re-centers
6. **T6: Repeat switch** — ws2→ws1 after retile/re-center → centered
7. **T7: Cross-monitor** — ws6(MBP)→ws1(G9) → window centered
8. **T8: Sketchybar highlights** — correct workspace highlighted after switch
9. **T9: MBP gaps** — MBP windows use normal 15px gaps, not G9's 1280px centered gaps
10. **T10: G9 stays centered when MBP focused** — switch to ws6(MBP) → G9 window stays centered
11. **T11: Hide window** — Cmd+H hide a window → sketchybar removes icon, centering unaffected; unhide → icon returns, re-centers
12. **T12: Minimize window** — minimize → sketchybar still shows icon (known gap: `isHidden` doesn't detect minimize), aerospace still lists the window; unminimize → re-centers properly
13. **T13: Minimize with 2 windows** — minimize one → remaining window centers; unminimize → both retile
14. **T15: Hide with 2 windows** — Cmd+H hide one → remaining window centers (NSWorkspace notification triggers re-evaluation)
15. **T17: Unhide retiles** — after hide→center→unhide, both windows retile at half width (not floating)
16. **T18: Quit app from different workspace** — 2 windows on ws1, switch to ws6, quit one → remaining window on ws1 re-centers (NSWorkspaceDidTerminateApplicationNotification)

### Other Notes

- **Per-monitor gaps:** Use `[{ monitor.'main' = X }, Y]` syntax. `'main'` = whichever display is set as primary in macOS.
- **Secondary display has no menu bar** — sketchybar sits at Y=0. The dock takes space at the bottom (auto-calculated by aerospace).
- **AeroSpace installed via Homebrew cask** (`nikitabobko/tap/aerospace`). The `.app` must be in `/Applications/`.
- **Accordion layout** = aerospace's stacking. Use `join-with` to group windows, `focus dfs-prev/dfs-next` to cycle within groups.
- **Prefer consistency over speed.** Always prefer deterministic, sequential operations over fast async ones.
- **Avoid arbitrary sleeps/delays** — they are non-deterministic and can cause race conditions.

## Window Management Stack (Windows — komorebi)

All configs live under `~/.config/komorebi/` (the stack folder):
- **Komorebi** — tiling window manager (`~/.config/komorebi/komorebi.json`)
- **komorebi-bar** — status bar (`~/.config/komorebi/komorebi.bar.mbp.json`, `~/.config/komorebi/komorebi.bar.g9.json`)
- **skhd** — hotkey daemon (`~/.config/komorebi/skhd/skhdrc`)
- **Management script:** `~/.local/bin/komo` (start/stop/restart/status) — manages launchctl agents for komorebi, komorebi-bar (x2 monitors), and skhd
- Theme: Catppuccin Mocha with Lavender accent
- Komorebi docs: <https://komorebi-starlight.lgug2z.workers.dev/>
- Legacy docs: <https://lgug2z.github.io/komorebi/>

## Documentation References

- AeroSpace: <https://nikitabobko.github.io/AeroSpace/guide>
- AeroSpaceBar: <https://github.com/rdrkr/AeroSpaceBar>
- JankyBorders: <https://github.com/FelixKratz/JankyBorders>
