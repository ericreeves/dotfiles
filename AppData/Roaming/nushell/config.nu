# Nushell Main Configuration
# This file is loaded after env.nu and contains aliases, custom commands,
# keybindings, and other shell configuration.

# Default Nushell configuration settings
$env.config = {
    show_banner: false
    use_grid_icons: true
    footer_mode: "25"
    float_precision: 2
    buffer_editor: ($env.EDITOR? | default "vi")
    use_ansi_coloring: true
    edit_mode: emacs
    
    # Table configuration
    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
    }
    
    # Completion configuration
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"
        external: {
            enable: true
            max_results: 100
            completer: null
        }
    }
    
    # History configuration
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }
    
    # Cursor shape configuration
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }
    
    # Color configuration
    color_config: {
        separator: "#8367c7"
        leading_trailing_space_bg: { attr: "n" }
        header: { fg: "#87ceeb" attr: "b" }
        empty: "#8367c7"
        bool: {|| if $in { "#98fb98" } else { "#ffb6c1" } }
        int: "#b0e0e6"
        filesize: {|e|
            if $e == 0b {
                "#8367c7"
            } else if $e < 1mb {
                "#98fb98"
            } else { "#87ceeb" }
        }
        duration: "#dda0dd"
        date: {|| (date now) - $in |
            if $in < 1hr {
                "#ff6347"
            } else if $in < 6hr {
                "#ffb6c1"
            } else if $in < 1day {
                "#ffdab9"
            } else if $in < 3day {
                "#f0e68c"
            } else if $in < 1wk {
                "#dda0dd"
            } else if $in < 6wk {
                "#87ceeb"
            } else if $in < 52wk {
                "#98fb98"
            } else { "#d3d3d3" }
        }
        range: "#dda0dd"
        float: "#b0e0e6"
        string: "#ffdab9"
        nothing: "#8367c7"
        binary: "#8367c7"
        cellpath: "#d3d3d3"
        row_index: { fg: "#98fb98" attr: "b" }
        record: "#8367c7"
        list: "#8367c7"
        block: "#8367c7"
        hints: "#d3d3d3"
    }
}

# Load modules
use modules/core/mod.nu *
use modules/navigation/mod.nu *
use modules/development/mod.nu *
use modules/utilities/mod.nu *
use modules/completions/mod.nu *

# External tool initialization
# Starship prompt
if (which starship | length) > 0 {
    let starship_cache = "~/.cache/starship"
    let starship_init = $"($starship_cache)/init.nu"
    
    # Create cache directory if it doesn't exist
    if not ($starship_cache | path exists) {
        mkdir $starship_cache
    }
    
    # Generate and source starship init only if file doesn't exist or starship is newer
    if not ($starship_init | path exists) {
        starship init nu | save -f $starship_init
    }
    
    source $starship_init
}

# Zoxide integration
if (which zoxide | length) > 0 {
    let zoxide_init = "~/.cache/zoxide.nu"
    
    # Generate and source zoxide init only if file doesn't exist
    if not ($zoxide_init | path exists) {
        zoxide init nushell | save -f $zoxide_init
    }
    
    source $zoxide_init
}

# External completions setup
let carapace_completer = {|spans|
    # Check if carapace is available
    if (which carapace | length) > 0 {
        carapace $spans.0 nushell $spans | from json
    } else {
        []
    }
}

# Update completion configuration to use external completer
$env.config = ($env.config | upsert completions.external.completer $carapace_completer)

# Enhanced keybindings with FZF integration
$env.config = ($env.config | upsert keybindings [
    {
        name: fzf_file_search
        modifier: control
        keycode: char_f
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "fzc"
        }
    }
    {
        name: fzf_history_search
        modifier: control
        keycode: char_h
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "fh"
        }
    }
    {
        name: fzf_directory_search
        modifier: alt
        keycode: char_c
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "dzc"
        }
    }
    {
        name: fzf_ripgrep_search
        modifier: control
        keycode: char_g
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "fg"
        }
    }
])