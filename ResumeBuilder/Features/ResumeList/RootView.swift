import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Resume.title) private var resumes: [Resume]
    @State private var path: [Resume] = []
    @State private var refreshID = UUID()
    @State private var showCreateOptions = false

    var body: some View {
        NavigationStack(path: $path) {
            resumeList
                .navigationTitle("Resume Builder")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                addSample()
                            } label: {
                                Label("With Sample Data", systemImage: "doc.text.fill")
                            }
                            
                            Button {
                                addEmpty()
                            } label: {
                                Label("Empty Resume", systemImage: "doc")
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                .navigationDestination(for: Resume.self) { resume in
                    ModeSwitcherView(resume: resume)
                }
                .onAppear {
                    print("📋 RootView appeared. Resumes count: \(resumes.count)")
                    // Also try to fetch directly from context to verify
                    let descriptor = FetchDescriptor<Resume>(sortBy: [SortDescriptor(\.title)])
                    if let fetched = try? context.fetch(descriptor) {
                        print("📋 Direct fetch from context: \(fetched.count) resumes")
                        for (index, r) in fetched.enumerated() {
                            print("   [\(index)] \(r.title) - \(r.person.fullName) (ID: \(r.id))")
                        }
                    }
                    for (index, r) in resumes.enumerated() {
                        print("   [\(index)] \(r.title) - \(r.person.fullName) (ID: \(r.id))")
                    }
                }
                .onChange(of: path) { oldValue, newValue in
                    // When navigation path changes (user navigates back), refresh
                    if newValue.isEmpty && !oldValue.isEmpty {
                        // User navigated back to root - refresh the list
                        print("🔄 User navigated back, refreshing list...")
                        refreshID = UUID()
                    }
                }
                .id(refreshID)
        }
    }
    
    private var resumeList: some View {
        List {
            Section("Resumes") {
                if resumes.isEmpty {
                    emptyStateView
                } else {
                    resumeRows
                }
            }
        }
        .refreshable {
            // Pull to refresh - force SwiftData to reload
            print("🔄 Refreshing resumes...")
            // The @Query should automatically update, but we can force a view refresh
            await MainActor.run {
                refreshID = UUID()
            }
        }
    }
    
    private var emptyStateView: some View {
        Text("No resumes yet. Tap + to create one.")
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
    }
    
    private var resumeRows: some View {
        ForEach(resumes) { r in
            NavigationLink(value: r) {
                resumeRowView(resume: r)
            }
        }
        .onDelete(perform: delete)
    }
    
    private func resumeRowView(resume: Resume) -> some View {
        VStack(alignment: .leading) {
            Text(resume.person.fullName).font(.headline)
            Text(resume.person.headline).foregroundStyle(.secondary)
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { resumes[$0] }.forEach(context.delete)
        try? context.save()
    }

    private func addSample() {
        print("➕ Adding sample resume...")
        
        // Create detailed experience items
        let autodeskExp = ItemModel(
            headline: "LEAD IOS ENGINEER, NOVA APPS",
            subheadline: "2022-PRESENT",
            startDate: Date(timeIntervalSince1970: 1640995200), // Jan 1, 2022
            endDate: nil,
            bullets: [
                "Lead a multi-platform squad delivering quarterly releases of the Nova productivity suite, improving mobile MAU by 18% and sustaining 99% crash-free sessions.",
                "Own full-stack delivery across SwiftUI, Kotlin, and Spring Boot services, coordinating requirements with design, QA, and platform guilds.",
                "Designed secure sync APIs for file collaboration and permissions, partnering with infra teams to roll out zero-downtime migrations.",
                "Built an offline-first sync engine (Core Data + background tasks) that reduced failed writes in low-connectivity regions by 40%.",
                "Piloted on-device ML document tagging, compressing the model to under 40 MB while keeping inference latency below 50 ms."
            ],
            meta: ["location": "Austin, TX"]
        )
        
        // Create Summary section (no "Summary" headline - just bullets)
        let summaryItem = ItemModel(
            headline: "",
            subheadline: nil,
            startDate: nil,
            endDate: nil,
            bullets: [
                "Lead Mobile Engineer with 9+ years architecting secure, high-performance apps across productivity, fintech, and health. Ships user-facing features end to end, partners tightly with product, and keeps quality/observability top of mind. Comfortable leading teams through ambiguous roadmaps and mentoring engineers across platforms."
            ],
            meta: [:]
        )
        
        // Create Skills section items
        let mobileSkills = ItemModel(
            headline: "Mobile Development (Primary)",
            subheadline: nil,
            startDate: nil,
            endDate: nil,
            bullets: [
                "iOS: Swift, SwiftUI, Objective-C, Combine, CoreData, SiriKit, AVFoundation, MapKit, CoreML",
                "Flutter: Dart, Bloc, Provider, Cupertino & Material libraries",
                "Android: Kotlin, Jetpack, Compose, Retrofit",
                "Architecture: MVVM, Clean Architecture, modularization"
            ],
            meta: [:]
        )
        
        let backendSkills = ItemModel(
            headline: "Backend & Microservices",
            subheadline: nil,
            startDate: nil,
            endDate: nil,
            bullets: [
                "Spring Boot, Spring Batch, RESTful APIs, GraphQL, Docker, Java"
            ],
            meta: [:]
        )
        
        let cicdSkills = ItemModel(
            headline: "CI/CD & Observability",
            subheadline: nil,
            startDate: nil,
            endDate: nil,
            bullets: [
                "Jenkins, GitHub Actions, Fastlane, Docker, XCTest, Appium, Firebase",
                "Certified ScrumMaster (CSM) • AWS Solutions Architect training"
            ],
            meta: [:]
        )
        
        let securitySkills = ItemModel(
            headline: "Security & Compliance",
            subheadline: nil,
            startDate: nil,
            endDate: nil,
            bullets: [
                "GDPR, OAuth2, PCI-DSS, SOC2"
            ],
            meta: [:]
        )
        
        // Create sections
        let summarySection = SectionModel(kind: .summary, title: "Summary", items: [summaryItem], isVisible: true)
        let skillsSection = SectionModel(kind: .skills, title: "Skills", items: [mobileSkills, backendSkills, cicdSkills, securitySkills], isVisible: true)
        let experienceSection = SectionModel(kind: .experience, title: "Experience", items: [autodeskExp], isVisible: true)
        
        // Create person with full details
        let person = Person(
            fullName: "Jordan Rivera",
            headline: "Lead Mobile Engineer",
            email: "jordan.rivera@example.com",
            phone: "+1-555-010-2048",
            location: "Austin, TX",
            links: [
                LinkItem(label: "LinkedIn", url: "https://linkedin.com/in/sample-candidate"),
                LinkItem(label: "GitHub", url: "https://github.com/sample"),
                LinkItem(label: "Website", url: "https://sample.dev")
            ]
        )
        
        var resume = Resume(
            title: "Sample Resume - Lead Mobile Engineer",
            person: person,
            sections: [summarySection, skillsSection, experienceSection],
            theme: .default,
            layoutMode: .structured
        )
        
        // Reorder sections: Summary first, then Skills
        hoistSummaryAndSkills(&resume)
        
        print("📝 Inserting resume: \(resume.title)")
        print("   - Sections: \(resume.sections.count)")
        print("   - Person: \(resume.person.fullName)")
        
        // Check if theme already exists (ThemeModel has unique id)
        // Fetch all themes and find matching one, or use the default
        let allThemes = try? context.fetch(FetchDescriptor<ThemeModel>())
        let existingTheme = allThemes?.first(where: { $0.id == resume.theme.id })
        
        // Use existing theme or insert new one
        let themeToUse = existingTheme ?? resume.theme
        if existingTheme == nil {
            context.insert(themeToUse)
        }
        
        // Insert all nested models first (SwiftData requirement)
        for section in resume.sections {
            context.insert(section)
            for item in section.items {
                context.insert(item)
            }
        }
        
        // Update resume to use the theme
        resume.theme = themeToUse
        
        // Then insert the resume
        context.insert(resume)
        
        print("💾 Attempting to save resume...")
        print("   - Resume ID: \(resume.id)")
        print("   - Theme ID: \(resume.theme.id)")
        print("   - Sections count: \(resume.sections.count)")
        
        do {
            try context.save()
            print("✅ Context.save() completed without error")
            
            // Verify the save worked by fetching directly
            let descriptor = FetchDescriptor<Resume>(sortBy: [SortDescriptor(\.title)])
            let fetched = try context.fetch(descriptor)
            print("📊 Direct fetch after save: \(fetched.count) resumes")
            for r in fetched {
                print("   - \(r.title) (ID: \(r.id))")
            }
            
            // Force query to refresh by triggering a view update
            refreshID = UUID()
            
            // Small delay to ensure SwiftData has processed the save
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("📋 After save delay:")
                print("   - @Query count: \(self.resumes.count)")
                let delayedFetch = try? self.context.fetch(FetchDescriptor<Resume>())
                print("   - Direct fetch count: \(delayedFetch?.count ?? 0)")
                // Navigate to the newly created resume
                self.path.append(resume)
            }
        } catch {
            print("❌ Error saving resume: \(error)")
            print("Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
        }
    }
    
    private func addEmpty() {
        print("➕ Creating empty resume...")
        
        // Create a minimal empty resume
        let person = Person(
            fullName: "Your Name",
            headline: "Your Title",
            email: "your.email@example.com",
            phone: "+1-XXX-XXX-XXXX",
            location: "City, Country",
            links: []
        )
        
        let resume = Resume(
            title: "New Resume",
            person: person,
            sections: [],
            theme: .default,
            layoutMode: .structured
        )
        
        print("📝 Inserting empty resume: \(resume.title)")
        
        // Check if theme already exists
        let allThemes = try? context.fetch(FetchDescriptor<ThemeModel>())
        let existingTheme = allThemes?.first(where: { $0.id == resume.theme.id })
        
        // Use existing theme or insert new one
        let themeToUse = existingTheme ?? resume.theme
        if existingTheme == nil {
            context.insert(themeToUse)
        }
        
        // Update resume to use the theme
        resume.theme = themeToUse
        
        // Insert the resume
        context.insert(resume)
        
        print("💾 Attempting to save empty resume...")
        print("   - Resume ID: \(resume.id)")
        print("   - Theme ID: \(resume.theme.id)")
        
        do {
            try context.save()
            print("✅ Empty resume saved successfully")
            
            // Verify the save worked
            let descriptor = FetchDescriptor<Resume>(sortBy: [SortDescriptor(\.title)])
            let fetched = try context.fetch(descriptor)
            print("📊 Direct fetch after save: \(fetched.count) resumes")
            
            // Force query to refresh
            refreshID = UUID()
            
            // Navigate to the newly created resume
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("📋 After save delay, @Query count: \(self.resumes.count)")
                self.path.append(resume)
            }
        } catch {
            print("❌ Error saving empty resume: \(error)")
            print("Error details: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
        }
    }
    
    private func hoistSummaryAndSkills(_ r: inout Resume) {
        let order: [SectionKind] = [.summary, .skills]
        r.sections.sort { a, b in
            let ia = order.firstIndex(of: a.kind) ?? Int.max
            let ib = order.firstIndex(of: b.kind) ?? Int.max
            if ia != ib { return ia < ib }
            return a.title < b.title
        }
        // Strip accidental duplicate "Summary" heading lines inside the Summary item
        if let i = r.sections.firstIndex(where: { $0.kind == .summary }),
           !r.sections[i].items.isEmpty,
           r.sections[i].items[0].headline.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "summary" {
            r.sections[i].items[0].headline = ""  // keep only the paragraph bullets/body
        }
    }
}
