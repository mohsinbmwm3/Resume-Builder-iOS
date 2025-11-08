# Setup Guide

## Quick Start

### Method 1: Manual Xcode Setup (Recommended for beginners)

1. **Open Xcode** (version 15.0 or later)

2. **Create a new project**:
   - File → New → Project
   - Select **iOS** → **App**
   - Fill in:
     - Product Name: `ResumeBuilder`
     - Team: (Select your team)
     - Organization Identifier: `com.yourcompany` (or your preferred identifier)
     - Interface: **SwiftUI**
     - Language: **Swift**
     - ✅ **Check "Use SwiftData"**
     - Minimum Deployment: **iOS 17.0**
   - Click **Next** and choose a location

3. **Remove default files**:
   - Delete `ContentView.swift` (if exists)
   - Delete the default `App.swift` (if it conflicts)

4. **Add project files**:
   - In Xcode, right-click on your project name in the navigator
   - Select **Add Files to "ResumeBuilder"...**
   - Navigate to the `ResumeBuilder/` folder in this repository
   - Select all folders: `App`, `Core`, `Features`, `Resources`
   - Options:
     - ✅ **Copy items if needed** (checked)
     - ✅ **Create groups** (selected)
     - ✅ **Add to targets: ResumeBuilder** (checked)
   - Click **Add**

5. **Verify the structure**:
   Your project navigator should show:
   ```
   ResumeBuilder/
   ├── App/
   │   └── ResumeBuilderApp.swift
   ├── Core/
   │   ├── Models/
   │   │   └── Models.swift
   │   └── Extensions/
   │       └── Bindings+Default.swift
   ├── Features/
   │   ├── ResumeList/
   │   │   └── RootView.swift
   │   ├── ResumeEditor/
   │   │   ├── ModeSwitcherView.swift
   │   │   ├── TemplateEditorView.swift
   │   │   ├── TemplatePreview.swift
   │   │   └── FreeformCanvasView.swift
   │   └── Export/
   │       ├── PDFExport.swift
   │       ├── Attr.swift
   │       └── ShareSheet.swift
   └── Resources/
       └── Info.plist
   ```

6. **Build and Run**:
   - Select a simulator (iPhone 15 Pro recommended)
   - Press ⌘R or click the Play button
   - The app should launch successfully!

### Method 2: Using XcodeGen (For advanced users)

If you prefer using [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project:

1. **Install XcodeGen**:
   ```bash
   brew install xcodegen
   ```

2. **Generate the project**:
   ```bash
   cd /path/to/Resume-Builder-iOS
   xcodegen generate
   ```

3. **Open the generated project**:
   ```bash
   open ResumeBuilder.xcodeproj
   ```

4. **Build and Run** (⌘R)

## Troubleshooting

### Build Errors

**Error: "Cannot find type 'Resume' in scope"**
- Make sure all files are added to the target
- Check that `Models.swift` is included in the build

**Error: "Use of undeclared type 'RootView'"**
- Verify that `RootView.swift` is in the project
- Clean build folder: Product → Clean Build Folder (⇧⌘K)

**SwiftData errors**
- Ensure "Use SwiftData" was checked when creating the project
- Check that iOS deployment target is 17.0 or higher

### Runtime Issues

**App crashes on launch**
- Check the console for error messages
- Verify all model classes are properly marked with `@Model`
- Ensure the model container includes all model types

**PDF export not working**
- Check that you have proper permissions
- Verify the temporary directory is accessible

## Next Steps

After successful setup:

1. Run the app and create a sample resume
2. Explore the structured template mode
3. Try the free-form canvas mode
4. Export a PDF to test the export functionality

## Development Tips

- Use the **Preview** feature in Xcode to see SwiftUI views without running the full app
- Check the **Debug Navigator** to monitor SwiftData operations
- Use **Breakpoints** to debug PDF generation if needed

## Need Help?

- Check the main README.md for architecture details
- Review the code comments in each file
- Open an issue on GitHub if you encounter problems

