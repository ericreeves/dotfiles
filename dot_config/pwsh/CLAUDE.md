# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a PowerShell profile configuration repository that provides a comprehensive shell environment with aliases, functions, modules, and environment configurations.

## Architecture

The configuration is modular and consists of several core files:

- **main.ps1**: Entry point that sources all other configuration files
- **aliases.ps1**: Contains all function definitions and aliases organized by category
- **alias-manager.ps1**: JSON-based alias management system with functions to import, display, edit, and sync aliases
- **aliases.ps1**: Generated from alias.json when using the alias management system
- **modules.ps1**: Manages PowerShell module installation and imports
- **env.ps1**: Environment variables, PATH configuration, and tool settings
- **env-secret.ps1**: Secret environment variables (conditionally loaded if exists)

## Key Features

### Dual Alias System
The repository supports two approaches for managing aliases:
1. **Direct PowerShell functions** (aliases.ps1) - Traditional approach with inline function definitions
2. **JSON-based management** (alias-manager.ps1) - Modern approach using alias.json configuration

### Function Categories
Functions are organized into logical categories:
- Terminal utilities (clear, exit, system info)
- Git operations (status, add, commit, push workflows)
- Navigation (zoxide integration, directory shortcuts)
- File operations (clipboard utilities, file manipulation)
- Fuzzy finding (extensive FZF integration)
- Development tools (Terraform, Chezmoi, Doormat)
- System utilities (process management, DNS flushing)

### Tool Integration
- **FZF**: Extensive fuzzy finding capabilities for files, directories, processes, and history
- **Zoxide**: Smart directory navigation with frecency algorithm
- **Starship**: Cross-shell prompt customization
- **PSFzf**: PowerShell FZF integration
- **LazyGit**: Terminal-based Git UI

## Development Workflow

### Modifying Aliases
When adding or modifying aliases, you can use either approach:

1. **Direct editing**: Edit `aliases.ps1` directly and add functions with inline comments
2. **JSON management**: Use the alias management functions:
   - `Edit-Aliases` - Open alias.json for editing
   - `Import-Aliases` - Import aliases from JSON
   - `Show-Aliases` - Display all configured aliases
   - `Sync-AliasesToNative` - Generate aliases.ps1 from alias.json

### Environment Configuration
- Modify `env.ps1` for general environment settings
- PATH modifications should be added to the PATH construction in env.ps1
- Tool-specific configurations (FZF, PSReadLine) are centralized in env.ps1

### Module Management
The `modules.ps1` file handles automatic installation and import of required PowerShell modules. Add new modules to the `$modules` array.

## Key Commands

### Profile Management
- `help` or `Show-AliasHelp` - Display all available functions with descriptions
- `Show-AliasHelp -Category "Git"` - Show functions from specific category

### Common Development Tasks
- `lg` - Launch LazyGit for Git operations
- `n` - Open current directory in Neovim
- `e` - Open current directory in Windows Explorer
- `...` - Navigate to git root (or C:/ if not in git repo)

### Fuzzy Finding
- `fzc [d|u|c]` - Fuzzy find files and navigate to their directory
- `dzc [d|u|c]` - Fuzzy find directories and navigate to them
- `fh` - Fuzzy search command history
- `fg <pattern>` - Fuzzy search text in files using ripgrep

### Tool Shortcuts
- `tf*` - Terraform command shortcuts (tfp, tfa, tfaa, etc.)
- `cm*` - Chezmoi dotfiles management shortcuts
- `dm*` - Doormat authentication shortcuts