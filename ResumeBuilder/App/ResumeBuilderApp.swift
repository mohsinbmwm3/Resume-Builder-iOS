import SwiftUI
import SwiftData

@main
struct ResumeBuilderApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .background(Color(.systemBackground))
        }
        .modelContainer(for: [Resume.self, SectionModel.self, ItemModel.self, ThemeModel.self])
    }
}
