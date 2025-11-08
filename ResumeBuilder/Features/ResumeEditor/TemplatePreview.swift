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
                }
                .padding(.bottom, 8)

                ForEach(resume.sections.filter { $0.isVisible }) { section in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(section.title).font(.headline)
                        ForEach(section.items) { item in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.headline).bold()
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
