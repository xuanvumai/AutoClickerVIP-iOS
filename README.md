
# AutoClick VIP iOS

AutoClick VIP built with SwiftUI.

## Requirements

- iOS 16+
- Xcode
- XcodeGen

## Generate Xcode project

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

1. Open Actions.
2. Select AutoClick VIP iOS Build.
3. Select Run workflow.
4. Wait for build completion.
5. Download AutoClickVIP-iOS artifact.
