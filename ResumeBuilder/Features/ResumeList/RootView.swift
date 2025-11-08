import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Resume.title) private var resumes: [Resume]
    @State private var path: [Resume] = []

    var body: some View {
        NavigationStack(path: $path) {
            resumeList
                .navigationTitle("Resume Builder")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { addSample() } label: { Label("Add", systemImage: "plus") }
                    }
                }
                .navigationDestination(for: Resume.self) { resume in
                    ModeSwitcherView(resume: resume)
                }
                .onAppear {
                    print("📋 RootView appeared. Resumes count: \(resumes.count)")
                    for (index, r) in resumes.enumerated() {
                        print("   [\(index)] \(r.title) - \(r.person.fullName)")
                    }
                }
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
            Text(resume.title).font(.headline)
            Text(resume.person.fullName).foregroundStyle(.secondary)
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
            headline: "SENIOR SOFTWARE ENGINEER, AUTODESK",
            subheadline: "2022-PRESENT",
            startDate: Date(timeIntervalSince1970: 1640995200), // Jan 1, 2022
            endDate: nil,
            bullets: [
                "Lead a 6-engineer squad delivering 9 major releases of Fusion 360 & AutoCAD Mobile, driving +18% monthly active users and 99.3% crash-free sessions in 12 months.",
                "Owned full-stack delivery, contributing across native mobile (iOS/Android) and backend services (Spring Boot microservices and Spring Batch pipelines).",
                "Engineered scalable backend APIs for file sync, access control, and project migration workflows; collaborated with multiple client teams for seamless integration.",
                "Developed an offline first sync layer (Core Data + NSOperations + Background Modes) that cut failed writes by 42% in poor connectivity scenarios, boosting user retention for iOS and Android app.",
                "Integrated On-device AI and ML capabilities, slimmed a drawing-recognition model to run fully offline in <50MB, enabling real-time feature detection without cloud dependency."
            ],
            meta: ["location": "Pune, India"]
        )
        
        // Create Summary section (no "Summary" headline - just bullets)
        let summaryItem = ItemModel(
            headline: "",
            subheadline: nil,
            startDate: nil,
            endDate: nil,
            bullets: [
                "Senior Software Engineer with 9+ years architecting secure, high performance mobile and backend solutions across CAD/CAM, retail, banking, and healthcare. Delivered apps serving millions with 99%+ crash free sessions. Skilled in Mobile App Development, Clean and Secure Architecture, Spring Boot, and AWS. Ready to drive user centric innovation in a senior/lead role."
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
                "iOS: Swift, SwiftUI, Objective-C, Combine, SceneKit, CoreData, SiriKit, AVFoundation, EventKit, MapKit, Pods, SPM, LaunchDarkly, CoreML, Autolayout",
                "Flutter: Dart, Bloc, GetX, BLoC, Cupertino Widgets, Material Design, Provider",
                "Android: Java, Kotlin, Android SDK",
                "Architecture: MVVM, MVC, Clean Architecture"
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
                "Jenkins, Spinnaker, Docker, Browser Stack, Appium, Splunk, Dynatrace, Grafana, Firebase",
                "Attended AWS Solutions Architect official AWS training workshop",
                "Certified ScrumMaster (CSM)"
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
            fullName: "MOHSIN KHAN",
            headline: "Senior Software Engineer",
            email: "mohsinkhan845@gmail.com",
            phone: "+919009301310",
            location: "Magarpatta City, Pune MH, India 411028",
            links: [
                LinkItem(label: "LinkedIn", url: "https://linkedin.com/in/mohsinkhan845"),
                LinkItem(label: "GitHub", url: "https://github.com/mohsinbmwm3"),
                LinkItem(label: "Medium", url: "https://medium.com/@mohsinkhan")
            ]
        )
        
        var resume = Resume(
            title: "Mohsin Khan - Senior Software Engineer",
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
        
        // Insert all nested models first (SwiftData requirement)
        for section in resume.sections {
            context.insert(section)
            for item in section.items {
                context.insert(item)
            }
        }
        context.insert(resume.theme)
        
        // Then insert the resume
        context.insert(resume)
        
        do {
            try context.save()
            print("✅ Resume saved successfully. Total resumes: \(resumes.count)")
            
            // Navigate to the newly created resume
            // Since we're already on the main thread in a button action, we can directly modify path
            path.append(resume)
        } catch {
            print("❌ Error saving resume: \(error)")
            print("Error details: \(error.localizedDescription)")
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
