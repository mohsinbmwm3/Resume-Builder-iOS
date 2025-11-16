import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Binding var resume: Resume
    @State private var selectedSectionID: UUID?
    @State private var showSectionPicker = false
    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.modelContext) private var context

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
        .confirmationDialog("Select Section Type", isPresented: $showSectionPicker, titleVisibility: .visible) {
            Button("Summary") { addSection(kind: .summary) }
            Button("Experience") { addSection(kind: .experience) }
            Button("Education") { addSection(kind: .education) }
            Button("Skills") { addSection(kind: .skills) }
            Button("Projects") { addSection(kind: .projects) }
            Button("Achievements") { addSection(kind: .achievements) }
            Button("Custom") { addSection(kind: .custom) }
            Button("Cancel", role: .cancel) { }
        }
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
                        HStack {
                            TextField("Section Title (e.g., Skills)", text: $section.title)
                                .font(.headline)
                            Toggle("", isOn: $section.isVisible)
                        }
                        
                        if section.isVisible {
                            if section.kind == .summary {
                                // SPECIAL CASE: Summary = single multiline paragraph
                                SummarySectionEditor(section: $section, context: context)
                            } else {
                                // All other sections keep the existing item-based UI
                                ItemsListView(section: $section, context: context)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .onChange(of: section.items.count) { _, _ in
                        // Save when items are added/removed
                        try? context.save()
                    }
                }
                .onMove { from, to in
                    resume.sections.move(fromOffsets: from, toOffset: to)
                    try? context.save()
                }
                Button { showSectionPicker = true } label: { Label("Add New Section", systemImage: "text.badge.plus") }
                    .buttonStyle(.bordered)
            }
        }
    }

    private func addSection(kind: SectionKind) {
        let title: String
        switch kind {
        case .summary: title = "Summary"
        case .experience: title = "Experience"
        case .education: title = "Education"
        case .skills: title = "Skills"
        case .projects: title = "Projects"
        case .achievements: title = "Achievements"
        case .custom: title = "Custom"
        }
        
        // Create a fresh new section with empty item (with explicit UUID)
        let newItem = ItemModel(
            id: UUID(),
            headline: "",
            subheadline: nil,
            startDate: nil,
            endDate: nil,
            bullets: [],
            meta: [:]
        )
        // Insert item into context first (SwiftData requirement)
        context.insert(newItem)
        
        let newSection = SectionModel(kind: kind, title: title, items: [newItem], isVisible: true)
        // Insert section into context
        context.insert(newSection)
        // Append to resume sections
        resume.sections.append(newSection)
        // Save immediately
        try? context.save()
    }
}

// Wrapper to maintain stable item identity and order
private struct ItemWrapper: Identifiable {
    let id: UUID
    let index: Int
    let item: ItemModel
}

// Separate view to maintain stable item order and prevent copying
private struct ItemsListView: View {
    @Binding var section: SectionModel
    let context: ModelContext
    @State private var itemOrder: [UUID] = []
    @State private var hasInitialized = false
    
    var body: some View {
        Group {
            // Create wrappers in the stored order
            let wrappers = itemOrder.compactMap { itemID -> ItemWrapper? in
                guard let index = section.items.firstIndex(where: { $0.id == itemID }),
                      index < section.items.count else { return nil }
                return ItemWrapper(id: itemID, index: index, item: section.items[index])
            }
            
            ForEach(wrappers) { wrapper in
                ItemEditorView(
                    item: Binding(
                        get: { 
                            // Get item by ID from the actual array
                            guard let index = section.items.firstIndex(where: { $0.id == wrapper.id }),
                                  index < section.items.count else {
                                return ItemModel(headline: "", bullets: [])
                            }
                            return section.items[index]
                        },
                        set: { newValue in
                            // Find the item by ID and update it
                            guard let index = section.items.firstIndex(where: { $0.id == wrapper.id }),
                                  index < section.items.count else { return }
                            
                            // Create a completely new array to ensure SwiftData detects the change
                            var updatedItems = section.items
                            updatedItems[index] = newValue
                            section.items = updatedItems
                            
                            // Save immediately when item is modified
                            try? context.save()
                        }
                    ),
                    sectionKind: section.kind
                )
                .id("section-\(section.id.uuidString)-item-\(wrapper.id.uuidString)")
            }
            .onDelete { indexSet in
                // Delete from both order array and actual items array
                let idsToRemove = indexSet.map { wrappers[$0].id }
                itemOrder.removeAll { idsToRemove.contains($0) }
                section.items.removeAll { idsToRemove.contains($0.id) }
                // Save when items are deleted
                try? context.save()
            }
            
            Button {
                // Create a completely fresh new item with empty values
                let newItem = ItemModel(
                    id: UUID(),
                    headline: "",
                    subheadline: nil,
                    startDate: nil,
                    endDate: nil,
                    bullets: [],
                    meta: [:]
                )
                // Insert the item into context first (SwiftData requirement)
                context.insert(newItem)
                // Append to the end of both arrays (maintains order)
                section.items.append(newItem)
                itemOrder.append(newItem.id)
                // Save immediately to persist the change
                try? context.save()
            } label: {
                Label("Add Item to Section", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .onAppear {
            if !hasInitialized {
                initializeOrder()
                hasInitialized = true
            }
        }
        .onChange(of: section.items.count) { oldCount, newCount in
            // Only sync if items were added (not deleted, as deletion is handled explicitly)
            if newCount > oldCount {
                // Find new items and add them to the end of order
                let currentIDs = Set(itemOrder)
                let newIDs = section.items.map { $0.id }.filter { !currentIDs.contains($0) }
                itemOrder.append(contentsOf: newIDs)
            }
        }
    }
    
    private func initializeOrder() {
        // Initialize order from current items array order
        itemOrder = section.items.map { $0.id }
    }
}

// Separate view for each item to ensure proper binding isolation
private struct ItemEditorView: View {
    @Binding var item: ItemModel
    let sectionKind: SectionKind
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Use explicit bindings to prevent cross-contamination
            TextField("Item Title (e.g., Skill Name)", text: Binding(
                get: { item.headline },
                set: { newValue in
                    var updatedItem = item
                    updatedItem.headline = newValue
                    item = updatedItem
                }
            ))
            .font(.subheadline)
            
            TextField("Subtitle or Description (optional)", text: Binding(
                get: { item.subheadline ?? "" },
                set: { newValue in
                    var updatedItem = item
                    updatedItem.subheadline = newValue.isEmpty ? nil : newValue
                    item = updatedItem
                }
            ))
            .font(.caption)
            .foregroundStyle(.secondary)
            
            // Show bullets for editing (always show for skills, or if bullets exist)
            if sectionKind == .skills || !item.bullets.isEmpty {
                Text("Details:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                ForEach(item.bullets.indices, id: \.self) { bulletIndex in
                    HStack(alignment: .top, spacing: 4) {
                        Text("•")
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                        TextField("Detail point", text: Binding(
                            get: { 
                                guard bulletIndex < item.bullets.count else { return "" }
                                return item.bullets[bulletIndex]
                            },
                            set: { newValue in
                                var updatedItem = item
                                guard bulletIndex < updatedItem.bullets.count else { return }
                                updatedItem.bullets[bulletIndex] = newValue
                                item = updatedItem
                            }
                        ), axis: .vertical)
                        .lineLimit(3...6)
                    }
                    .padding(.vertical, 1)
                }
                .onDelete { indexSet in
                    var updatedItem = item
                    updatedItem.bullets.remove(atOffsets: indexSet)
                    item = updatedItem
                }
                Button {
                    var updatedItem = item
                    updatedItem.bullets.append("")
                    item = updatedItem
                } label: {
                    Label("Add Detail", systemImage: "plus.circle")
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .font(.caption)
            } else if sectionKind != .summary {
                // For non-skills sections, show option to add bullets
                Button {
                    var updatedItem = item
                    updatedItem.bullets.append("")
                    item = updatedItem
                } label: {
                    Label("Add Detail Point", systemImage: "plus.circle")
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .font(.caption)
            }
        }
        .padding(.vertical, 2)
        .padding(.leading, 8)
    }
}

// MARK: - Summary editor (multiline paragraph)
private struct SummarySectionEditor: View {
    @Binding var section: SectionModel
    let context: ModelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Summary text")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: Binding(
                get: {
                    // Ensure we always have at least one item backing the summary
                    if section.items.isEmpty {
                        let newItem = ItemModel(
                            id: UUID(),
                            headline: "",
                            subheadline: nil,
                            startDate: nil,
                            endDate: nil,
                            bullets: [],
                            meta: [:]
                        )
                        context.insert(newItem)
                        section.items = [newItem]
                        try? context.save()
                    }
                    return section.items.first?.headline ?? ""
                },
                set: { newValue in
                    guard !section.items.isEmpty else { return }
                    // Update via a copy so SwiftData detects the change
                    var updatedItems = section.items
                    updatedItems[0].headline = newValue
                    section.items = updatedItems
                    try? context.save()
                }
            ))
            .font(.body)
            .frame(minHeight: 140, alignment: .topLeading)
            .scrollContentBackground(.hidden)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(uiColor: .separator), lineWidth: 0.5)
            )
        }
        .padding(.vertical, 4)
    }
}
