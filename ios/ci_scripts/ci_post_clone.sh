#!/bin/sh
set -e

cd $CI_PRIMARY_REPOSITORY_PATH

echo "==> Downloading Flutter 3.22.3..."
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.22.3 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

# Generate the Podfile (this creates one post_install block already)
flutter build ios --config-only

# Patch the existing post_install block to also force iOS 15.0 on all pods
# We replace the flutter_additional_ios_build_settings(target) line and add the
# deployment target fix right after it, inside the same loop
sed -i '' 's/flutter_additional_ios_build_settings(target)/flutter_additional_ios_build_settings(target)\n      target.build_configurations.each do |config|\n        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"\n      end/' ios/Podfile

echo "==> Podfile after patch:"
cat ios/Podfile

echo "==> Running pod install..."
cd ios
pod install

exit 0
