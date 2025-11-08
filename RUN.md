# How to Run Resume Builder iOS

## Quick Start Options

### Option 1: Using Xcode (Recommended for Development)

#### Step 1: Create the Xcode Project

**Method A: Using XcodeGen (Fastest)**

```bash
# Install XcodeGen if you don't have it
brew install xcodegen

# Generate the project
xcodegen generate

# Open in Xcode
open ResumeBuilder.xcodeproj
```

**Method B: Manual Setup in Xcode**

1. Open **Xcode**
2. **File** → **New** → **Project**
3. Select **iOS** → **App**
4. Fill in the details:
   - **Product Name**: `ResumeBuilder`
   - **Team**: Select your development team
   - **Organization Identifier**: `com.yourcompany` (or your preferred)
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - ✅ **Check "Use SwiftData"**
   - **Minimum Deployment**: **iOS 17.0**
5. Click **Next** and save in this directory
6. Delete default files (`ContentView.swift`, `App.swift` if they exist)
7. **Right-click** on your project in navigator → **Add Files to "ResumeBuilder"...**
8. Select the `ResumeBuilder/` folder
9. Options:
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets: ResumeBuilder**
10. Click **Add**

#### Step 2: Run in Xcode

1. Select a **simulator** (e.g., iPhone 15 Pro)
2. Press **⌘R** or click the **Play** button
3. The app will build and launch in the simulator

---

### Option 2: Command Line (Using xcodebuild)

#### Prerequisites

First, you need an Xcode project. Use one of the methods above to create it.

#### Build the Project

```bash
# Build for simulator
xcodebuild -project ResumeBuilder.xcodeproj \
           -scheme ResumeBuilder \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
           build
```

#### Run in Simulator

```bash
# Build and run in simulator
xcodebuild -project ResumeBuilder.xcodeproj \
           -scheme ResumeBuilder \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
           test
```

Or use `xcrun simctl` to launch the app:

```bash
# First, build the app
xcodebuild -project ResumeBuilder.xcodeproj \
           -scheme ResumeBuilder \
           -sdk iphonesimulator \
           -configuration Debug \
           -derivedDataPath ./build

# Then install and launch (you'll need the app bundle path)
# This is more complex - Xcode is easier for running
```

#### List Available Simulators

```bash
xcrun simctl list devices available
```

#### Build for Device

```bash
# Build for physical device (requires code signing)
xcodebuild -project ResumeBuilder.xcodeproj \
           -scheme ResumeBuilder \
           -sdk iphoneos \
           -configuration Release \
           CODE_SIGN_IDENTITY="Apple Development" \
           DEVELOPMENT_TEAM="YOUR_TEAM_ID"
```

---

### Option 3: Using the Setup Script

```bash
# Make the script executable
chmod +x setup_xcode.sh

# Run the setup script
./setup_xcode.sh
```

The script will:
- Check if XcodeGen is installed
- Generate the project if available
- Provide instructions if manual setup is needed

---

## Common Commands

### Build Commands

```bash
# Clean build folder
xcodebuild clean -project ResumeBuilder.xcodeproj -scheme ResumeBuilder

# Build for Debug
xcodebuild -project ResumeBuilder.xcodeproj \
           -scheme ResumeBuilder \
           -configuration Debug \
           -sdk iphonesimulator

# Build for Release
xcodebuild -project ResumeBuilder.xcodeproj \
           -scheme ResumeBuilder \
           -configuration Release \
           -sdk iphonesimulator
```

### Testing Commands

```bash
# Run tests
xcodebuild test -project ResumeBuilder.xcodeproj \
                -scheme ResumeBuilder \
                -sdk iphonesimulator \
                -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Archive Commands (for App Store)

```bash
# Create archive
xcodebuild archive -project ResumeBuilder.xcodeproj \
                   -scheme ResumeBuilder \
                   -archivePath ./build/ResumeBuilder.xcarchive \
                   -configuration Release
```

---

## Troubleshooting

### "No such module 'SwiftData'"
- Ensure you checked "Use SwiftData" when creating the project
- Check that iOS deployment target is 17.0 or higher

### "Cannot find type 'Resume' in scope"
- Verify all files are added to the target
- Check Build Phases → Compile Sources includes all Swift files

### Build Errors
```bash
# Clean and rebuild
xcodebuild clean -project ResumeBuilder.xcodeproj -scheme ResumeBuilder
xcodebuild -project ResumeBuilder.xcodeproj -scheme ResumeBuilder -sdk iphonesimulator
```

### Simulator Issues
```bash
# List all simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Shutdown all simulators
xcrun simctl shutdown all
```

---

## Recommended Workflow

**For Development:**
- Use **Xcode** (⌘R to run, ⌘B to build)
- Use **Preview** (⌘⌥P) to see SwiftUI views instantly
- Use **Debug Navigator** to monitor SwiftData

**For CI/CD:**
- Use **xcodebuild** commands in your build scripts
- Use **fastlane** for automation (optional)

**For Quick Testing:**
- Use the setup script: `./setup_xcode.sh`
- Then open in Xcode: `open ResumeBuilder.xcodeproj`

---

## Next Steps

1. ✅ Set up the project (using one of the methods above)
2. ✅ Build and run (⌘R in Xcode)
3. ✅ Create a sample resume
4. ✅ Test PDF export
5. ✅ Start customizing!

For more details, see `SETUP.md` and `README.md`.

