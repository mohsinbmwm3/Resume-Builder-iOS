import SwiftUI

struct ModeSwitcherView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSize
    @State var resume: Resume
    @State private var showShare = false
    @State private var pdfURL: URL?
    @State private var compactTab: Int = 0 // 0 = Edit, 1 = Preview

    var body: some View {
        Group {
            if hSize == .compact {
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
                                TemplateEditorView(resume: $resume)
                            } else {
                                TemplatePreview(resume: resume)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        case .freeform:
                            FreeformCanvasView(resume: $resume)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 0) {
                    Picker("Layout Mode", selection: $resume.layoutMode) {
                        Text("Structured").tag(LayoutMode.structured)
                        Text("Free-Form").tag(LayoutMode.freeform)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    Divider()

                    Group {
                        switch resume.layoutMode {
                        case .structured:
                            TemplateEditorView(resume: $resume)
                        case .freeform:
                            FreeformCanvasView(resume: $resume)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle(resume.title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { exportPDF() } label: { Label("Export PDF", systemImage: "square.and.arrow.up") }
            }
        }
        // The key line: paint the full-screen background, ignoring safe areas,
        // so you don't see system black around your content.
        .background(Color(.systemBackground).ignoresSafeArea())
        .sheet(isPresented: $showShare) {
            if let pdfURL { ShareSheet(items: [pdfURL]) }
        }
        .onChange(of: resume) { _, newValue in
            context.insert(newValue)
            try? context.save()
        }
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
