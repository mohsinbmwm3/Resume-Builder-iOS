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

                        if section.kind == .summary {
                            // SUMMARY = paragraphs only (no bold item titles)
                            ForEach(section.items) { item in
                                // Prefer bullets as paragraphs; else use headline/subheadline if present
                                let paras: [String] = item.bullets.isEmpty
                                    ? [item.headline, item.subheadline ?? ""].filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                                    : item.bullets

                                ForEach(paras, id: \.self) { para in
                                    Text(para)
                                        .font(.body)                 // regular
                                        .lineSpacing(3)
                                        .padding(.bottom, 2)
                                }
                            }
                        } else {
                            // EXISTING rendering for all other sections
                            ForEach(section.items) { item in
                                VStack(alignment: .leading, spacing: 2) {
                                    // Title – same as before
                                    Text(item.headline)
                                        .font(.body)
                                        .bold()

                                    // Subtitle – smaller + grey, like Edit screen
                                    if let sub = item.subheadline, !sub.isEmpty {
                                        Text(sub)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    // Details / bullets
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
