#!/usr/bin/env bash
echo "Updating Brew"
brew update

TAPS="aws/tap wallix/awless homebrew/cask-fonts"
for t in ${TAPS}; do
    echo "Tapping ${t}..."
    brew tap ${t}
done

PACKAGES="git hub tmux bat fzf ctags \
readline awscli aws-iam-authenticator aws-sam-cli \
awless cfn-lint helm htop iftop jq kops lame nmap \
python sops terraform watch wget zsh ack coreutils fluxctl \
eksctl"

for p in ${PACKAGES}; do 
    echo "Installing ${p}..."
    brew install ${p}
done

echo "Cleaning up..."
brew cleanup

echo "Installing cask..."
CASKS="hyper slack visual-studio-code steam 1password \
macdown aws-vault bartender boom-3d caffeine disk-inventory-x \
docker dropbox google-chrome google-drive-file-stream \
jira-client karabiner-elements macpass spectacle stellarium \
steermouse the-unarchiver zoomus font-hack-nerd-font discord \
vlc"

for c in ${CASKS}; do
    echo "Installing ${c}..."
    brew cask install ${c}
done

#echo "Installing Python packages..."
#PYTHON_PACKAGES=(
#    virtualenv
#    virtualenvwrapper
#)
#sudo pip install ${PYTHON_PACKAGES[@]}

