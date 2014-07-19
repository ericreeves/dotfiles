##############################################################################
# Git Prompt Stuff
#
# Adapted from code found at <https://gist.github.com/1712320>.

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
#GIT_PROMPT_SYMBOL="%{$fg_bold[black]%}[%b%{$fg[blue]%}±%{$fg_bold[black]%}]"
GIT_PROMPT_SYMBOL=""
GIT_PROMPT_PREFIX="%{$fg_bold[black]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg_bold[black]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi

}

#########################
# Prompt Module Functions
# 
# Building these out as functions makes final prompt assembly easier
#

# If inside a Git repository, print its branch and state
function git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[white]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}


function vc_symbol {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo '○'
}

function vc_prompt_string() {
  echo -n "%{$fg_bold[black]%}[%{$reset_color%}"
  echo -n "%{$fg[blue]%}$(vc_symbol)"
  echo -n "%{$fg_bold[black]%}]%{$reset_color%}"
  echo
}

function date_time_prompt_string() {
  echo "%{$reset_color%}%{$fg_bold[black]%}[%{$reset_color%}%{$fg[white]%}%D{%Y-%m-%d} %*%{$fg_bold[black]%}]%{$reset_color%}"
}

function date_prompt_string() {
  echo "%{$reset_color%}%{$fg_bold[black]%}[%{$reset_color%}%{$fg[white]%}%D{%Y-%m-%d}%{$fg_bold[black]%}]%{$reset_color%}"
}

function time_prompt_string() {
  echo "%{$reset_color%}%{$fg_bold[black]%}[%{$reset_color%}%{$fg[white]%}%*%{$fg_bold[black]%}]%{$reset_color%}"
}

function user_host_path_string() {
  echo "%{$fg_bold[black]%}[%{$reset_color%}%{$fg[white]%}%n%{$fg_bold[black]%}@%{$reset_color%}%{$fg_bold[white]%}%m%{$fg_bold[black]%}:%{$reset_color%}%{$fg_bold[white]%}%~%{$fg[grey]%}]"
}

function battery_charge {
      echo -n "%{$fg_bold[black]%}[%{$reset_color%}"
      echo -n `~/bin/batcharge.py` 2>/dev/null
      echo -n "%{$fg_bold[black]%}]%{$reset_color%}"
      echo
}

function prompt_char() {
  if [ $UID -eq "0" ]; then
    echo "%{$reset_color%}%{$fg[red]%}#%{$reset_color%}"
  else
    echo "%{$reset_color%}%{$fg[blue]%}$%{$reset_color%}"
  fi
}

# Build the prompt!
PS1=$'$(user_host_path_string) $(time_prompt_string)
$(vc_prompt_string)$(git_prompt_string)$(prompt_char) '

# With a hamburger!
#PS1=$'$(user_host_path_string) $(time_prompt_string)
#$(vc_prompt_string)$(git_prompt_string)🍔 $(prompt_char) '

#RPS1='$(battery_charge)'
#RPS1='$(date_time_prompt_string)'

#[~/Development/al-chef/production/al-tmc] [git:(blah)::] [02:09:55]
#[Cygnus:eric]$
#PROMPT=$'%{$fg[grey]%}%B[%{$reset_color%}%{$fg_bold[white]%}%~%{$fg[grey]%}] [%{$reset_color%}$(git_prompt)%{$fg_bold[black]%}] %{$fg[grey]%}[%b%{$fg[white]%}%D{%I:%M:%S}%{$fg_bold[black]%}] 
#%{$fg_bold[black]%}[%{$fg_bold[white]%}%m%{$fg_bold[black]%}:%{$reset_color%}%{$fg[white]%}%n%{$fg_bold[black]%}]%{$fg_bold[black]%}%B%{$fg[blue]%}$(prompt_char) '
#PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '

#PROMPT=$'%{$fg[grey]%}%B┌─[%{$reset_color%}$fg[white]%}%n%{$fg_bold[black]%}@%{$fg_bold[white]%}%m%{$fg_bold[grey]%}:%{$fg_bold[white]%}%~%{$fg[grey]%}] [%{$reset_color%}$(git_prompt)$(hg_prompt_info)%B%{$fg_bold[black]%}] %{$fg[grey]%}[%b%{$fg[white]%}'%D{"%I:%M:%S"}%{$fg_bold[black]%}]'
#%{$fg_bold[black]%}%B└─%{$fg[blue]%}$% %{$reset_color%} '
#PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '

#PROMPT=$'%{$fg[grey]%}%B┌─[%b%{\e[0m%}%{$fg[white]%}%n%{$fg_bold[black]%}@%{$fg_bold[white]%}%m%{$fg[grey]%}%B]%b%b%{$fg[grey]m%}%B[%b%{$fg_bold[white]%}%~%{$fg[grey]%}%B]%b%{\e[0m%}%{$fg[grey]m%}%B[%b%{$fg[white]%}'%D{"%Y-%m-%d %I:%M:%S"}%b$'%{$fg[grey]%}%B]%b
#%{$fg_bold[black]%}%B└─%B[%{$fg[blue]%}$%{$fg_bold[black]%}%B] <%{$fg_bold[grey]%}$(git_prompt)$(hg_prompt_info)>%{\e[0m%}%b '
#PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '
#
#

#
# Litex Bashrc
#

# rbenv
eval "$(rbenv init -)"

# Setup the prompt, including curent git branch
function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

# VI
export EDITOR="vim"
set -o vi

tab_blue
title "localhost"
