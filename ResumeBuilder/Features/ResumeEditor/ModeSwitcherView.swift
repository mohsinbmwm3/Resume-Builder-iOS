import SwiftUI

struct ModeSwitcherView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSize
    @Bindable var resume: Resume
    @State private var showShare = false
    @State private var pdfURL: URL?
    @State private var compactTab: Int = 0 // 0 = Edit, 1 = Preview

    var body: some View {
        contentView
            .navigationTitle(resume.person.fullName)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { exportPDF() } label: { Label("Export PDF", systemImage: "square.and.arrow.up") }
                }
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .sheet(isPresented: $showShare) {
                if let pdfURL { ShareSheet(items: [pdfURL]) }
            }
            .onChange(of: resume.title) { _, _ in
                try? context.save()
            }
            .onChange(of: resume.person) { _, _ in
                try? context.save()
            }
            .onChange(of: resume.sections) { _, _ in
                try? context.save()
            }
            .onDisappear {
                // Final save when leaving the view
                try? context.save()
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if hSize == .compact {
            compactBody
        } else {
            regularBody
        }
    }
    
    @ViewBuilder
    private var compactBody: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $compactTab) {
                Text("Edit").tag(0)
                Text("Preview").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            Divider()
            
            Group {
                switch resume.layoutMode {
                case .structured:
                    if compactTab == 0 {
                        editorView
                    } else {
                        TemplatePreview(resume: resume)
                    }
                case .freeform:
                    canvasView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var regularBody: some View {
        VStack(spacing: 0) {
            Picker("Layout Mode", selection: Binding(
                get: { resume.layoutMode },
                set: { newValue in
                    resume.layoutMode = newValue
                    try? context.save()
                }
            )) {
                Text("Structured").tag(LayoutMode.structured)
                Text("Free-Form").tag(LayoutMode.freeform)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            Group {
                switch resume.layoutMode {
                case .structured:
                    editorView
                case .freeform:
                    canvasView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var editorView: some View {
        TemplateEditorView(resume: Binding(
            get: { resume },
            set: { newValue in
                // Update the resume properties
                resume.title = newValue.title
                resume.person = newValue.person
                resume.sections = newValue.sections
                resume.theme = newValue.theme
                resume.layoutMode = newValue.layoutMode
                resume.blocks = newValue.blocks
                try? context.save()
            }
        ))
    }
    
    @ViewBuilder
    private var canvasView: some View {
        FreeformCanvasView(resume: Binding(
            get: { resume },
            set: { newValue in
                // Update the resume properties
                resume.title = newValue.title
                resume.person = newValue.person
                resume.sections = newValue.sections
                resume.theme = newValue.theme
                resume.layoutMode = newValue.layoutMode
                resume.blocks = newValue.blocks
                try? context.save()
            }
        ))
    }

    private func exportPDF() {
        do {
            let data = try PDFExport.makePDF(resume: resume)
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("Resume-\(resume.id).pdf")
            try data.write(to: tmp)
            pdfURL = tmp
            showShare = true
        } catch {
            print("Export error: \(error)")
        }
    }
}
