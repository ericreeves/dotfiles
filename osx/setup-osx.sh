#!/bin/bash
echo "--- Installing Homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
if [ $? -ne 0 ]; then
	echo "*** Homebrew install failed"
fi

echo "--- Installin brew-cask"
brew install caskroom/cask/brew-cask

BREW_PACKAGES='git git-flow hub tmux wget oauthtool'
echo "--- Installing Brew packages ($BREW_PACKAGES)"
for b in $BREW_PACKAGES; do 
	brew install $b
done

CASKS='caffeine iterm2 spectacle the-unarchiver'
echo "--- Installing Brew Casks ($CASKS)"
for c in $CASKS; do
	brew cask install $c
done

echo "Setup computer name"
#sudo scutil --set ComputerName "Cygnus"
#sudo scutil --set HostName "Cygnus"
#sudo scutil --set LocalHostName "Cygnus"
#sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "Cygnus"

echo "Disable the 'Are you sure you want to open this application?' dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Disable Notification Center and remove the menu bar icon"
#launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

echo "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

echo "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

echo "Disable sound effect when changing volume"
defaults write -g com.apple.sound.beep.feedback -integer 0

echo "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

echo "Kill affected applications, so the changes apply"
for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done

git config --global user.email 'eric@alertlogic.com'; git config --global user.name 'Eric Reeves'
