#!/bin/sh

# The default execution directory of this script is the ci_scripts directory.
# Change working directory to the root of your cloned repo.
cd $CI_PRIMARY_REPOSITORY_PATH 

# Install Flutter using git.
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.22.3 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Pre-cache iOS artifacts
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

# Install CocoaPods dependencies.
cd ios
pod install

exit 0
