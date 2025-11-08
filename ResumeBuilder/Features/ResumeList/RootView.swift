import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Resume.title) private var resumes: [Resume]
    @State private var path: [Resume] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Resumes") {
                    ForEach(resumes) { r in
                        NavigationLink(value: r) {
                            VStack(alignment: .leading) {
                                Text(r.title).font(.headline)
                                Text(r.person.fullName).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Resume Builder")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { addSample() } label: { Label("Add", systemImage: "plus") }
                }
            }
            .navigationDestination(for: Resume.self) { resume in
                ModeSwitcherView(resume: resume)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { resumes[$0] }.forEach(context.delete)
        try? context.save()
    }

    private func addSample() {
        let exp = ItemModel(headline: "Autodesk", subheadline: "Senior Software Engineer", startDate: Date(timeIntervalSince1970: 1609459200), endDate: nil, bullets: ["Lead iOS auth overhaul (ASWebAuthSession)", "Built Swift concurrency-based image loader"], meta: ["location":"Pune"])
        let s1 = SectionModel(kind: .experience, title: "Experience", items: [exp])
        let resume = Resume(title: "iOS Engineer – 1 page", person: Person(fullName: "Mohsin Khan", headline: "Senior Software Engineer", email: "mohsin@example.com", phone: "+91-0000000000", location: "Pune"), sections: [s1], theme: .default, layoutMode: .structured)
        context.insert(resume)
        try? context.save()
    }
}
