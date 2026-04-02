# AeroSpace Ultrawide Fork Plan

## Status: Not yet implemented

## Problem
Single windows on the G9 ultrawide (5120x1440) stretch to full width. Current workaround uses a Rust helper that edits `outer.left/right` gaps via sed + `aerospace reload-config`. This works but causes visual flash and requires complex edge-case handling (18 test cases).

## Better Solution: Cherry-pick PR #1512
PR [nikitabobko/AeroSpace#1512](https://github.com/nikitabobko/AeroSpace/pull/1512) adds native `single-window-max-width-percent` to aerospace's layout engine. One config option, zero external tooling. The PR was rejected by the maintainer (wants to design it himself) but the code is clean and self-contained.

### Config
```toml
# Center single windows on G9 at 50% width (2560px of 5120px)
single-window-max-width-percent = [{ monitor.'main' = 50 }, 100]
single-window-exclude-app-ids = []
```

### Implementation Steps
1. Clone upstream: `git clone https://github.com/nikitabobko/AeroSpace.git ~/code/aerospace-custom`
2. Checkout release: `git checkout v0.20.3-Beta`
3. Fetch PR: `git fetch origin pull/1512/head:pr-1512`
4. Cherry-pick: `git cherry-pick 50e3eae92f20`
5. Build: `./build-release.sh --build-version 0.20.3-custom`
6. Install to `/Applications/AeroSpace.app` (backup existing first)
7. Update `aerospace.toml` with `single-window-max-width-percent`
8. Simplify Rust helper (remove gap management, keep sketchybar/borders/notifications)

### PR touches these files
- `Sources/AppBundle/command/impl/FullscreenCommand.swift`
- `Sources/AppBundle/config/Config.swift`
- `Sources/AppBundle/config/parseConfig.swift`
- `Sources/AppBundle/config/parseGaps.swift`
- `Sources/AppBundle/layout/layoutRecursive.swift`
- `Sources/AppBundle/tree/Window.swift`
- `Sources/Common/cmdArgs/impl/FullscreenCmdArgs.swift`

### Alternative: pauldub/AeroSpace fork
Cloned at `~/code/pauldub-aerospace`. Has `single-window-margin` (pixel-based) and `center-expand` command. 10 commits ahead of upstream, 215 behind. Has automated daily rebase. More features but more complex than PR #1512.

### Risks
- Cherry-pick may conflict against v0.20.3-Beta (PR was against `main`)
- Custom build = no Homebrew updates, manual rebuilds on new releases
- Upstream may implement differently, requiring migration
