#!/bin/bash
set -euo pipefail

# Display message 'Setting up your Mac...'
echo "Setting up Mac..."
sudo -v

# Homebrew - Installation
echo "Installing Homebrew"

if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# System Settings

echo "System Setup - Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Disable the “Are you sure you want to open this application?” dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Wipe all (default) app icons from the Dock"
echo "This is only really useful when setting up a new Mac, or if you don’t use"
echo "the Dock to launch apps."
defaults write com.apple.dock persistent-apps -array

echo "Dark menu bar and dock"
defaults write $HOME/Library/Preferences/.GlobalPreferences.plist AppleInterfaceTheme -string "Dark"

echo "Use list view in all Finder windows by default"
echo "Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

echo "Configuring screenshots to save in Screenshots"
defaults write com.apple.screencapture location ~/Screenshots
killall SystemUIServer

# Mousr

# Note: Need to add double finger tap to right click as automated setting.

# Safari

echo "Privacy: don’t send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Photos

echo "Prevent Photos from opening automatically when devices are plugged in"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Set macOS preferences
# We will run this last because this will reload the shell
# source .macos # need this?

# Install Homebrew Packages

cd ~
echo "Installing Homebrew packages"

homebrew_packages=(
  "git"
  "mysql"
  "php"
  "sqlite"
  "node"
)

for homebrew_package in "${homebrew_packages[@]}"; do
  brew install "$homebrew_package"
done

# Install Casks
echo "Installing Homebrew cask packages"
brew tap caskroom/fonts

homebrew_cask_packages=(
  "authy"
  "discord"
  "font-fira-code"
  "font-quicksand"
  "google-chrome"
  "postman"
  "iterm2"
  "rocket"
  "spotify"
  "sublime-text"
  "sketch"
  "visual-studio-code"
)

for homebrew_cask_package in "${homebrew_cask_packages[@]}"; do
  brew cask install "$homebrew_cask_package"
done

# Install Composer
echo "Installing Composer"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install Global Composer Packages
echo "Installing Global Composer Packages"
/usr/local/bin/composer global require laravel/installer laravel/valet statamic/cli

# Install Laravel Valet
echo "Installing Laravel Valet"
$HOME/.composer/vendor/bin/valet install

# Create Sites directory
echo "Creating a Sites directory"
mkdir $HOME/Sites

# Start MySQL for the first time
echo "Starting MySQL for the first time"
brew services start mysql

# Configure Laravel Valet
cd ~/Sites
valet park && cd ~
echo "Configuring Laravel Valet"
cd ~
valet restart

# Installing Global Node Dependecies
echo "Installing Global Node Dependecies"
npm install -g @angular/cli
npm install -g firebase-tools

# Generate SSH key
echo "Generating SSH keys"
ssh-keygen -t rsa

echo "Copied SSH key to clipboard - You can now add it to Github"
pbcopy < ~/.ssh/id_rsa.pub

# Complete
echo "Installation Complete"