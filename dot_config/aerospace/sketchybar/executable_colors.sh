#!/bin/bash

# Source central colorscheme
source "$HOME/.config/colorscheme.sh"

# Convert hex to sketchybar format (0xAARRGGBB)
export BAR_COLOR=0xd9${COLOR_BG}
export BAR_BORDER_COLOR=0xff${COLOR_BG_TERTIARY}
export TEXT_COLOR=0xff${COLOR_FG}
export ACCENT_COLOR=0xff${COLOR_ACCENT}
export HIGHLIGHT=0xff${COLOR_BG_SECONDARY}
export INACTIVE=0xff${COLOR_INACTIVE}
export SUBTLE=0xff${COLOR_SUBTLE}
export RED=0xff${COLOR_RED}
export ORANGE=0xff${COLOR_ORANGE}
export YELLOW=0xff${COLOR_YELLOW}
export GREEN=0xff${COLOR_GREEN}
export BLUE=0xff${COLOR_BLUE}
export PURPLE=0xff${COLOR_PURPLE}
export PINK=0xff${COLOR_PINK}
export LAVENDER=0xff${COLOR_LAVENDER}
export TRANSPARENT=0x00000000
