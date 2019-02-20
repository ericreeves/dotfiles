# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    source ~/.zplug/init.zsh && zplug update --self
fi

# Enable VI mode
bindkey -v
export KEYTIMEOUT=1

# Enable Zplug
source ~/.zplug/init.zsh

# What does this do?
zplug "junegunn/fzf-bin", \
    from:gh-r, \
    at:0.11.0, \
    as:command, \
    use:"*darwin*amd64*", \
    rename-to:fzf
# It grabs the binary of fzf-bin version 0.11.0 from GitHub Release and uses
# the file that matches "*darwin*amd64" as a command called fzf!

#zplug "denysdovhan/spaceship-zsh-theme", use:spaceship.zsh, from:github, as:theme

zplug mafredri/zsh-async, from:github
zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

#zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme

zplug "zsh-users/zsh-syntax-highlighting"

# History Search
zplug "zsh-users/zsh-history-substring-search"
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# History Settings
HISTFILE=$HOME/.zhistory
HISTSIZE=100000
SAVEHIST=100000
setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history # share command history data

zplug "zsh-users/zsh-completions"

export PATH="/usr/local/opt/python/libexec/bin:$PATH"
#VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3

#zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
#source =virtualenvwrapper.sh

### Actually Install zPlug Plugins
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose

# Check initial directory for any .venv file
#check_venv

# Include Eric's Aliases and Environment
source ~/.zshrc.eric
source ~/.zshrc.token
