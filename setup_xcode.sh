#!/bin/bash

# Resume Builder iOS - Xcode Project Setup Script
# This script helps you set up the Xcode project

set -e

echo "🚀 Resume Builder iOS - Setup Script"
echo "======================================"
echo ""

# Check if XcodeGen is installed
if command -v xcodegen &> /dev/null; then
    echo "✅ XcodeGen found!"
    echo ""
    echo "Generating Xcode project with XcodeGen..."
    xcodegen generate
    echo ""
    echo "✅ Project generated successfully!"
    echo ""
    echo "To open the project:"
    echo "  open ResumeBuilder.xcodeproj"
    echo ""
    echo "To build from command line:"
    echo "  xcodebuild -project ResumeBuilder.xcodeproj -scheme ResumeBuilder -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build"
    echo ""
    echo "To run in simulator:"
    echo "  xcodebuild -project ResumeBuilder.xcodeproj -scheme ResumeBuilder -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test"
    exit 0
fi

# If XcodeGen is not installed
echo "⚠️  XcodeGen not found."
echo ""
echo "You have two options:"
echo ""
echo "Option 1: Install XcodeGen (Recommended)"
echo "  brew install xcodegen"
echo "  Then run this script again: ./setup_xcode.sh"
echo ""
echo "Option 2: Manual Setup in Xcode"
echo "  1. Open Xcode"
echo "  2. File → New → Project"
echo "  3. Choose iOS → App"
echo "  4. Fill in:"
echo "     - Product Name: ResumeBuilder"
echo "     - Interface: SwiftUI"
echo "     - Language: Swift"
echo "     - ✅ Check 'Use SwiftData'"
echo "     - Minimum Deployment: iOS 17.0"
echo "  5. Save the project in this directory"
echo "  6. Delete default ContentView.swift and App.swift (if they exist)"
echo "  7. Right-click project → Add Files to 'ResumeBuilder'..."
echo "  8. Select the 'ResumeBuilder' folder"
echo "  9. Check 'Copy items if needed' and 'Create groups'"
echo "  10. Click Add"
echo ""
echo "For detailed instructions, see SETUP.md"

