#!/bin/sh
cd $CI_PRIMARY_REPOSITORY_PATH 

echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.22.3 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

# Generate Podfile and Xcode project files for plugins
flutter build ios --config-only

# Update deployment target in Podfile if it was generated with an older version
cd ios
if [ -f "Podfile" ]; then
    sed -i '' "s/platform :ios, '12.0'/platform :ios, '15.0'/g" Podfile
    sed -i '' "s/platform :ios, '11.0'/platform :ios, '15.0'/g" Podfile
fi

HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
pod install

exit 0
