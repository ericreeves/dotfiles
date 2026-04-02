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
- Theme: Catppuccin Lavender borders
- Central colorscheme: `~/.config/colorscheme.sh`

### AeroSpace Behavioral Notes

- **No runtime gap adjustment** — `aerospace gaps` subcommand doesn't exist. Gaps are config-only. Single-window centering on the G9 is achieved by floating + osascript repositioning, not gap changes.
- **`exec-on-workspace-change`** fires on workspace switches. Use for centering logic.
- **`on-focus-changed`** fires on every focus change (window switch, monitor switch, new window spawn). Runs very frequently — keep callbacks lightweight. Never put osascript positioning here (causes flicker/races).
- **Dynamic gaps split into two scripts:**
  - `dynamic_gaps.sh` — full logic (center/retile), runs on workspace change only
  - `dynamic_gaps_retile.sh` — lightweight retile-only check, runs on focus change. Catches new windows spawned on same workspace.
- **State files** in `/tmp/aerospace_dynamic_gaps/` track per-workspace centering state to avoid redundant repositioning.
- **Hidden windows:** macOS apps can be hidden (`Cmd+H`) but AeroSpace still lists them as windows. Use `osascript` to query `visible is false` app processes. Match by bundle ID (`%{app-bundle-id}`), not app name — aerospace app names often differ from System Events process names (e.g., "Mantle" vs "mantle-tauri").
- **Per-monitor gaps:** Use `[{ monitor.'main' = X }, Y]` syntax. `'main'` = whichever display is set as primary in macOS (has the menu bar), not a specific physical monitor.
- **Secondary display has no menu bar** — sketchybar sits at Y=0. The dock takes space at the bottom. AeroSpace automatically accounts for the dock in its tiling area.
- **Retina scaling:** The MBP is 3024x1964 Retina, rendered as ~1512x982 points. Aerospace gap values are in points.
- **osascript window positioning:** Y coordinates are in global screen space. With stacked displays, the MBP starts at Y=1440 (below G9). Target the specific app process by name, not "frontmost app" — avoids positioning wrong window during monitor switches.
- **AeroSpace installed via Homebrew cask** (`nikitabobko/tap/aerospace`). The `.app` must be in `/Applications/` — if missing, `brew reinstall --cask aerospace` fixes it.
- **Accordion layout** = aerospace's stacking. Use `join-with` to group windows, `focus dfs-prev/dfs-next` to cycle within groups.
- **Never use `aerospace enable off/on`** to reposition windows — it breaks sketchybar rendering and causes race conditions. Use `aerospace resize` with absolute values on floating windows instead (aerospace auto-centers them).
- **Prefer consistency over speed.** Always prefer deterministic, sequential operations over fast async ones. Avoid `&` backgrounding for positioning operations.
- **Avoid arbitrary sleeps/delays** — they are non-deterministic and can cause race conditions. Instead, confirm the previous action completed (e.g., query state, check return code) before proceeding. Only use sleep as a last resort when no verification method exists.

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
