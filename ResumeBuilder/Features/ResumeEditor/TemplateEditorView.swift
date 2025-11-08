import SwiftUI

struct TemplateEditorView: View {
    @Binding var resume: Resume
    @State private var selectedSectionID: UUID?
    @Environment(\.horizontalSizeClass) private var hSize

    var body: some View {
        Group {
            if hSize == .compact {
                formList
                    .listStyle(.insetGrouped)
            } else {
                HStack(spacing: 0) {
                    formList
                        .frame(minWidth: 320, idealWidth: 360, maxWidth: 420)
                        .listStyle(.insetGrouped)

                    Divider()

                    TemplatePreview(resume: resume)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Ensure editor also paints a full-screen background
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private var formList: some View {
        List(selection: $selectedSectionID) {
            Section("Profile") {
                TextField("Full name", text: Binding(get: { resume.person.fullName }, set: { resume.person.fullName = $0 }))
                TextField("Headline", text: Binding(get: { resume.person.headline }, set: { resume.person.headline = $0 }))
                TextField("Email", text: Binding(get: { resume.person.email }, set: { resume.person.email = $0 }))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                TextField("Phone", text: Binding(get: { resume.person.phone }, set: { resume.person.phone = $0 }))
                    .keyboardType(.phonePad)
                TextField("Location", text: Binding(get: { resume.person.location }, set: { resume.person.location = $0 }))
            }
            
            // Links editor
            Section("Links") {
                if resume.person.links.isEmpty {
                    Text("Add LinkedIn, GitHub, Medium…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                ForEach($resume.person.links) { $link in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Label (e.g., LinkedIn)", text: $link.label)
                        TextField("URL (https://…)", text: $link.url)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { idx in resume.person.links.remove(atOffsets: idx) }
                
                Button {
                    resume.person.links.append(.init(label: "LinkedIn", url: "https://"))
                } label: {
                    Label("Add Link", systemImage: "link.badge.plus")
                }
            }

            Section("Sections") {
                ForEach($resume.sections) { $section in
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $section.isVisible) { Text(section.title) }
                        if section.isVisible {
                            ForEach($section.items) { $item in
                                VStack(alignment: .leading, spacing: 6) {
                                    TextField("Headline", text: $item.headline)
                                    TextField("Subheadline", text: Binding($item.subheadline, default: ""))
                                    
                                    // Show bullets for editing
                                    if !item.bullets.isEmpty || section.kind == .skills {
                                        Text("Bullets:")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        ForEach(Array(item.bullets.enumerated()), id: \.offset) { index, bullet in
                                            HStack(alignment: .top, spacing: 6) {
                                                Text("•")
                                                    .foregroundStyle(.secondary)
                                                TextField("Bullet point", text: Binding(
                                                    get: { item.bullets[index] },
                                                    set: { item.bullets[index] = $0 }
                                                ), axis: .vertical)
                                                .lineLimit(3...6)
                                            }
                                        }
                                        .onDelete { indexSet in
                                            item.bullets.remove(atOffsets: indexSet)
                                        }
                                        Button {
                                            item.bullets.append("New bullet point")
                                        } label: {
                                            Label("Add Bullet", systemImage: "plus.circle")
                                        }
                                        .buttonStyle(.borderless)
                                        .controlSize(.small)
                                        .font(.caption)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete { indexSet in
                                section.items.remove(atOffsets: indexSet)
                            }
                            Button {
                                section.items.append(ItemModel(headline: "New Item", bullets: []))
                            } label: {
                                Label("Add Item", systemImage: "plus")
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onMove { from, to in
                    resume.sections.move(fromOffsets: from, toOffset: to)
                }
                Button { addSection() } label: { Label("Add Section", systemImage: "text.badge.plus") }
                    .buttonStyle(.bordered)
            }
        }
    }

    private func addSection() {
        resume.sections.append(SectionModel(kind: .custom, title: "Custom", items: [ItemModel(headline: "Detail")]))
    }
}
