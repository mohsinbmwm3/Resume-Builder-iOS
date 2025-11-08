import SwiftUI

struct TemplatePreview: View {
    let resume: Resume

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(resume.person.fullName).font(.title2).bold()
                    Text(resume.person.headline)
                    Text("\(resume.person.email) • \(resume.person.phone) • \(resume.person.location)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    // Links row - show labels only
                    if !resume.person.links.isEmpty {
                        Text(resume.person.links.map(\.label).joined(separator: "  •  "))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.top, 4)
                    }
                }
                .padding(.bottom, 8)

                ForEach(resume.sections.filter { $0.isVisible }) { section in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(section.title).font(.headline)
                        
                        // Two-column layout for Skills section
                        if section.kind == .skills {
                            let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible())]
                            LazyVGrid(columns: cols, alignment: .leading, spacing: 6) {
                                ForEach(section.items) { item in
                                    Text("• \(item.headline)")
                                        .font(.callout)
                                }
                            }
                        } else {
                            // Regular items rendering
                            ForEach(section.items) { item in
                                VStack(alignment: .leading, spacing: 2) {
                                    // For Summary section, skip empty headlines
                                    if section.kind != .summary || !item.headline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text(item.headline).bold()
                                    }
                                    if let sub = item.subheadline, !sub.isEmpty { Text(sub) }
                                    ForEach(item.bullets, id: \.self) { b in
                                        HStack(alignment: .top, spacing: 6) {
                                            Text("•")
                                            Text(b)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .frame(maxWidth: 720)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        // Critical: paint the background under the scroll view to screen edges
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
