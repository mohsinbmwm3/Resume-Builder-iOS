# Resume Builder iOS

A modern iOS resume builder application built with SwiftUI and SwiftData, supporting both structured templates and free-form canvas editing modes.

## Features

- 📝 **Structured Template Mode**: Create ATS-friendly resumes with predefined sections
- 🎨 **Free-Form Canvas Mode**: Design custom resumes with drag-and-drop blocks
- 📄 **PDF Export**: Export your resume as a professional PDF
- 💾 **SwiftData Persistence**: All resumes are automatically saved using SwiftData
- 🎯 **Clean Architecture**: Well-organized codebase following clean architecture principles

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Project Structure

```
ResumeBuilder/
├── App/
│   └── ResumeBuilderApp.swift          # App entry point
├── Core/
│   ├── Models/
│   │   └── Models.swift                 # Data models (Resume, SectionModel, ItemModel, etc.)
│   └── Extensions/
│       └── Bindings+Default.swift       # SwiftUI binding extensions
├── Features/
│   ├── ResumeList/
│   │   └── RootView.swift               # Main resume list view
│   ├── ResumeEditor/
│   │   ├── ModeSwitcherView.swift       # Mode switcher (Structured/Free-form)
│   │   ├── TemplateEditorView.swift     # Structured template editor
│   │   ├── TemplatePreview.swift        # Live preview of structured template
│   │   └── FreeformCanvasView.swift     # Free-form canvas editor
│   └── Export/
│       ├── PDFExport.swift              # PDF generation logic
│       ├── Attr.swift                   # PDF text styling utilities
│       └── ShareSheet.swift             # Share sheet for PDF export
└── Resources/
    └── Info.plist                       # App configuration
```

## Setup Instructions

### Option 1: Create New Xcode Project (Recommended)

1. Open Xcode and create a new project:
   - Choose **iOS** → **App**
   - Product Name: `ResumeBuilder`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ✅ Check **Use SwiftData**
   - Minimum Deployment: **iOS 17.0**

2. Delete the default `ContentView.swift` and `App.swift` files

3. Add all files from the `ResumeBuilder/` directory to your Xcode project:
   - Right-click on your project in the navigator
   - Select **Add Files to "ResumeBuilder"...**
   - Navigate to the `ResumeBuilder/` folder
   - Select all folders and files
   - Make sure **"Copy items if needed"** is checked
   - Ensure **"Create groups"** is selected
   - Click **Add**

4. Build and run the project (⌘R)

### Option 2: Use XcodeGen (Advanced)

If you have [XcodeGen](https://github.com/yonaskolb/XcodeGen) installed:

```bash
# Install XcodeGen (if not already installed)
brew install xcodegen

# Generate Xcode project
xcodegen generate
```

## Architecture

The project follows **Clean Architecture** principles:

- **App Layer**: Application entry point and configuration
- **Core Layer**: Domain models and shared utilities
- **Features Layer**: Feature modules organized by functionality
  - Each feature is self-contained with its views and logic
  - Features can be easily extended or modified independently

## Usage

1. **Create a Resume**: Tap the "+" button to create a new resume with sample data
2. **Edit Profile**: Update your personal information in the Profile section
3. **Add Sections**: Add and customize sections like Experience, Education, Skills, etc.
4. **Switch Modes**: Toggle between Structured and Free-Form modes
5. **Export PDF**: Tap the export button to generate and share your resume as PDF

## Data Models

- **Resume**: Main resume document containing person info, sections, and blocks
- **SectionModel**: Represents a section (Experience, Education, etc.)
- **ItemModel**: Individual items within a section
- **ThemeModel**: Theme configuration for styling
- **Block**: Free-form canvas blocks (text or image)

## Future Enhancements

- [ ] Date pickers & metadata editors for items
- [ ] Image picker for free-form image blocks
- [ ] Undo/redo using UndoManager
- [ ] Theme switcher (colors/fonts) and A4 paper option
- [ ] Section presets (Experience/Education/Skills) templates
- [ ] Import/export of Resume as JSON for backup
- [ ] ATS checker (keyword density vs target JD)

## License

See LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
