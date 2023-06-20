#!/bin/bash
# macOS.sh
# author: peter.maltby1
# created: 2023-06-20
#############################################################
dotfilesRepo="https://github.com/PeterMaltby/.dotfiles.git"

gitDir="${HOME}/gitrepos"
dotfilesDir="${gitDir}/.dotfiles"

#############################################################
# bootstrap
if ! cd "$HOME"; then
	echo "cannot move to ${HOME}, user likely incorrect"
	exit 1
fi

mkdir "$gitDir"

if ! cd "$gitDir"; then
	echo "cannot move to ${gitDir}"
	exit 1
fi

if ! git clone $dotfilesRepo "$dotfilesDir"; then
    echo "cannot clone $dotfilesRepo"
    exit 1
fi

if ! cd "$dotfilesDir"; then
    echo "cannot move to $dotfilesDir"
    exit 1
fi

# run bootstrap script for configs
if ! "${dotfilesDir}/bootstrap.sh"; then
    echo "bootstrap failed!"
    exit 1
fi

echo "bootstrap completed succesfully, PABLO should now be working!"

#############################################################

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install    firefox \
                librewolf \
                figlet \
                htop \
                noefetch \
                neovim \
                sops \
                slack \
                microsoft-teams \
                microsoft-outlook \
                thunderbird \
                resilio-sync \
                spotify \
				alacritty

osascript -e 'tell application "System Preferences" to quit'

# set all the settings
sudo nvram SystemAudioVolume=" "
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write com.apple.LaunchServices LSQuarantine -bool false

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

defaults write com.apple.screencapture location -string "${HOME}/Desktop"

defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool true

defaults write com.apple.dock show-process-indicators -bool true

defaults write com.apple.dock launchanim -bool false

defaults write com.apple.dock expose-animation-duration -float 0.1

defaults write com.apple.dashboard mcx-disabled -bool true
defaults write com.apple.dock dashboard-in-overlay -bool true
defaults write com.apple.dock mru-spaces -bool false

defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false

defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

