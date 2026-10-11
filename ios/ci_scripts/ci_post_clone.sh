#!/bin/sh
set -e

cd $CI_PRIMARY_REPOSITORY_PATH

echo "==> Downloading Flutter 3.22.3..."
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.22.3 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

# Generate the Podfile and other iOS config files
flutter build ios --config-only

# Inject a post_install hook into the Podfile that forces all pods to iOS 15.0
cat >> ios/Podfile << 'PODFILE_HOOK'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
PODFILE_HOOK

echo "==> Installing CocoaPods..."
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

cd ios
pod install

exit 0
