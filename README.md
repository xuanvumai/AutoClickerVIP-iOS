
# AutoClickerVIP-iOS

AutoClick VIP - SwiftUI iOS project.

## Requirements

- Xcode
- iOS 16+
- XcodeGen

## Generate project

```bash
xcodegen generate
```

## Build

```bash
xcodebuild \
  -project AutoClickerVIP.xcodeproj \
  -scheme AutoClickerVIP \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## GitHub Actions

Open Actions and select:

AutoClickerVIP iOS Build

Then select Run workflow.

The unsigned IPA is available in Artifacts.
