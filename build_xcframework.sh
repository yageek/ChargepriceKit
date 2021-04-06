#!/bin/sh

### Based on: https://pspdfkit.com/blog/2020/supporting-xcframeworks/
### Variables used to parameters the build

PROJECT_NAME="ChargepriceKit"
OUTPUT_DIR="$(pwd)/universal-build"
CONFIGURATION="Release"

### Variables depending on configuration
SIMULATOR_BUILD="${OUTPUT_DIR}/build-iphonesimulator"
DEVICE_BUILD="${OUTPUT_DIR}/build-iphoneos"
### Main script

echo "⚙️ Starting building universal framework"

# Create the output/buildir directory
mkdir -p "${OUTPUT_DIR}"

### Compilation for both variant

echo "📱 Building iOS versions"
xcodebuild archive -project "${PROJECT_NAME}.xcodeproj" -scheme "${PROJECT_NAME}-iOS" -configuration ${CONFIGURATION} -destination 'generic/platform=iOS' -archivePath "${OUTPUT_DIR}/${PROJECT_NAME}.framework-iphoneos.xcarchive" SKIP_INSTALL=NO | xcpretty

xcodebuild archive -project "${PROJECT_NAME}.xcodeproj" -scheme "${PROJECT_NAME}-iOS" -configuration ${CONFIGURATION} -destination 'generic/platform=iOS Simulator' -archivePath "${OUTPUT_DIR}/${PROJECT_NAME}.framework-iphonesimulator.xcarchive" SKIP_INSTALL=NO | xcpretty

xcodebuild archive -project "${PROJECT_NAME}.xcodeproj" -scheme "${PROJECT_NAME}-iOS" -configuration ${CONFIGURATION} -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' -archivePath "${OUTPUT_DIR}/${PROJECT_NAME}.framework-catalyst.xcarchive" SKIP_INSTALL=NO | xcpretty

echo "🖥 Building mac versions"
xcodebuild archive -project "${PROJECT_NAME}.xcodeproj" -scheme "${PROJECT_NAME}-macOS" -configuration ${CONFIGURATION} -destination 'generic/platform=macOS' -archivePath "${OUTPUT_DIR}/${PROJECT_NAME}.framework-macOS.xcarchive" SKIP_INSTALL=NO | xcpretty

echo "⚙️ Assembling"
xcodebuild -create-xcframework \
-framework "${OUTPUT_DIR}/${PROJECT_NAME}.framework-iphoneos.xcarchive/Products/Library/Frameworks/ChargepriceKit.framework" \
-framework "${OUTPUT_DIR}/${PROJECT_NAME}.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/ChargepriceKit.framework" \
-framework "${OUTPUT_DIR}/${PROJECT_NAME}.framework-catalyst.xcarchive/Products/Library/Frameworks/ChargepriceKit.framework" \
-framework "${OUTPUT_DIR}/${PROJECT_NAME}.framework-macOS.xcarchive/Products/Library/Frameworks/ChargepriceKit.framework" \
-output "${OUTPUT_DIR}/${PROJECT_NAME}.xcframework"
