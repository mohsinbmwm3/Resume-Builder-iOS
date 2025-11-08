import SwiftUI

struct ModeSwitcherView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSize
    var resume: Resume
    @State private var showShare = false
    @State private var pdfURL: URL?
    @State private var compactTab: Int = 0 // 0 = Edit, 1 = Preview
    @State private var resumeState: Resume
    
    init(resume: Resume) {
        self.resume = resume
        self._resumeState = State(initialValue: resume)
    }
    
    private var resumeBinding: Binding<Resume> {
        $resumeState
    }

    var body: some View {
        mainContent
            .navigationTitle(resumeState.title)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { exportPDF() } label: { Label("Export PDF", systemImage: "square.and.arrow.up") }
                }
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .sheet(isPresented: $showShare) {
                if let pdfURL { ShareSheet(items: [pdfURL]) }
            }
            .onChange(of: resumeState) { _, newValue in
                context.insert(newValue)
                try? context.save()
            }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if hSize == .compact {
            compactLayout
        } else {
            regularLayout
        }
    }
    
    private var compactLayout: some View {
        VStack(spacing: 0) {
            compactPicker
            Divider()
            compactContentView
        }
    }
    
    private var compactPicker: some View {
        Picker("View", selection: $compactTab) {
            Text("Edit").tag(0)
            Text("Preview").tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var compactContentView: some View {
        Group {
            switch resumeState.layoutMode {
            case .structured:
                if compactTab == 0 {
                    TemplateEditorView(resume: resumeBinding)
                } else {
                    TemplatePreview(resume: resumeState)
                }
            case .freeform:
                FreeformCanvasView(resume: resumeBinding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var regularLayout: some View {
        VStack(spacing: 0) {
            regularPicker
            Divider()
            regularContentView
        }
    }
    
    private var regularPicker: some View {
        Picker("Layout Mode", selection: $resumeState.layoutMode) {
            Text("Structured").tag(LayoutMode.structured)
            Text("Free-Form").tag(LayoutMode.freeform)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    @ViewBuilder
    private var regularContentView: some View {
        Group {
            switch resumeState.layoutMode {
            case .structured:
                TemplateEditorView(resume: resumeBinding)
            case .freeform:
                FreeformCanvasView(resume: resumeBinding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func exportPDF() {
        do {
            let data = try PDFExport.makePDF(resume: resumeState)
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("Resume-\(resumeState.id).pdf")
            try data.write(to: tmp)
            pdfURL = tmp
            showShare = true
        } catch {
            print("Export error: \(error)")
        }
    }
}
