# Project Structure

## Directory Tree

```
Resume-Builder-iOS/
├── ResumeBuilder/
│   ├── App/
│   │   └── ResumeBuilderApp.swift          # App entry point with SwiftData container
│   ├── Core/
│   │   ├── Models/
│   │   │   └── Models.swift                 # Domain models (Resume, SectionModel, ItemModel, ThemeModel, Block)
│   │   └── Extensions/
│   │       └── Bindings+Default.swift       # SwiftUI binding extensions
│   ├── Features/
│   │   ├── ResumeList/
│   │   │   └── RootView.swift               # Main resume list with navigation
│   │   ├── ResumeEditor/
│   │   │   ├── ModeSwitcherView.swift       # Toggle between Structured/Free-form modes
│   │   │   ├── TemplateEditorView.swift     # Structured template editor with form
│   │   │   ├── TemplatePreview.swift        # Live preview of structured resume
│   │   │   └── FreeformCanvasView.swift     # Free-form canvas with draggable blocks
│   │   └── Export/
│   │       ├── PDFExport.swift              # PDF generation for both modes
│   │       ├── Attr.swift                   # NSAttributedString styling utilities
│   │       └── ShareSheet.swift             # UIActivityViewController wrapper
│   └── Resources/
│       └── Info.plist                       # App configuration
├── .gitignore                                # Git ignore rules
├── project.yml                               # XcodeGen configuration (optional)
├── README.md                                 # Main documentation
├── SETUP.md                                  # Detailed setup instructions
└── PROJECT_STRUCTURE.md                      # This file
```

## Architecture Layers

### 1. App Layer
- **Purpose**: Application entry point and configuration
- **Files**: `ResumeBuilderApp.swift`
- **Responsibilities**: 
  - Initialize SwiftData model container
  - Set up root view hierarchy

### 2. Core Layer
- **Purpose**: Shared domain models and utilities
- **Subdirectories**:
  - `Models/`: Data models using SwiftData
  - `Extensions/`: SwiftUI and Foundation extensions
- **Responsibilities**:
  - Define data structures
  - Provide reusable utilities

### 3. Features Layer
- **Purpose**: Feature modules organized by functionality
- **Subdirectories**:
  - `ResumeList/`: Resume listing and navigation
  - `ResumeEditor/`: Resume editing (both modes)
  - `Export/`: PDF generation and sharing
- **Responsibilities**:
  - Implement user-facing features
  - Handle feature-specific logic

### 4. Resources Layer
- **Purpose**: App configuration and assets
- **Files**: `Info.plist`
- **Responsibilities**:
  - App metadata
  - Configuration settings

## Clean Architecture Benefits

✅ **Separation of Concerns**: Each layer has a clear responsibility  
✅ **Testability**: Models and logic can be tested independently  
✅ **Maintainability**: Easy to locate and modify features  
✅ **Scalability**: New features can be added without affecting existing code  
✅ **Reusability**: Core models and utilities are shared across features  

## Dependencies

- **SwiftUI**: UI framework
- **SwiftData**: Data persistence
- **UIKit**: PDF generation and sharing (via UIViewControllerRepresentable)

