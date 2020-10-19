#!/bin/bash

# Override Defaults With My Dotfiles
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/zshrc.config ~/.zshrc.config
ln -sf ~/dotfiles/zshrc.token ~/.zshrc.token
ln -sf ~/dotfiles/p10k.zsh ~/.p10k.zsh

ln -sf ~/dotfiles/hyper.js ~/.hyper.js
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf