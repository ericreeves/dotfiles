#!/bin/zsh

# Install zpresto
if [ ! -d ~/.zprezto ]; then
  echo "*** ~/.zprezto does not exist.  Cloning for you..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto
  exit 1
fi
if [ ! -d ~/.zprezto ]; then
  echo "*** ~/.zprezto create failed.  Aborting..."
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
ln -sf ~/dotfiles/zshrc.eric ~/.zshrc.eric
ln -sf ~/dotfiles/zshrc.token ~/.zshrc.token

# Install spf13
if [ ! -d ~/.spf13-vim-3 ]; then
	curl http://j.mp/spf13-vim3 -L -o - | sh
fi

# VIM configs
ln -sf ~/dotfiles/vim/vimrc.before.local ~/.vimrc.before.local
ln -sf ~/dotfiles/vim/vimrc.bundles.local ~/.vimrc.bundles.local
ln -sf ~/dotfiles/vim/vimrc.local ~/.vimrc.local
ln -sf ~/dotfiles/vim/gvimrc ~/.gvimrc
# Install VIM plugins
#vim +BundleInstall! +BundleClean +q
