#!/bin/zsh

# Install zpresto
if [ ! -d ~/.zprezto ]; then
  echo "*** ~/.zprezto does not exist.  Aborting..."
  exit 1
fi

# Setup zpresto
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# Override Defaults With My Dotfiles
ln -sf ~/dotfiles/prompts/prompt_litex_setup ~/.zprezto/modules/prompt/functions/prompt_litex_setup
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/zpreztorc ~/.zpreztorc
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
