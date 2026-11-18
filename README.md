
# AutoClick VIP iOS

SwiftUI AutoClick VIP.

## Requirements
- iOS 16+
- Xcode
- XcodeGen

## Generate
xcodegen generate

## Build
xcodebuild \
  -project AutoClickerVIP.xcodeproj \
  -scheme AutoClickerVIP \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGNING_ALLOWED=NO \
  build

## GitHub Actions
Open Actions and select:
AutoClickerVIP iOS Build

Run workflow and download the IPA artifact.
