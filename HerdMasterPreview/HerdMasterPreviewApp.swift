import SwiftUI
import SwiftData

@main
struct HerdMasterPreviewApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Animal.self,
            BreedingRecord.self,
            SyncConflict.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var hasSeeded = false

    var body: some View {
        TabView {
            OnboardingView()
                .tabItem {
                    Label("Onboarding", systemImage: "sparkles")
                }

            HerdListView()
                .tabItem {
                    Label("Herd", systemImage: "hare.fill")
                }

            EvansImportDemoView()
                .tabItem {
                    Label("Import", systemImage: "square.and.arrow.down")
                }

            PedigreeDemoView()
                .tabItem {
                    Label("Pedigree", systemImage: "square.stack.3d.up")
                }
        }
        .tint(HMColor.accent)
        .onAppear {
            seedIfNeeded()
        }
    }

    private func seedIfNeeded() {
        guard !hasSeeded else { return }
        hasSeeded = true

        let existing = try? modelContext.fetch(FetchDescriptor<Animal>())
        guard existing?.isEmpty ?? true else { return }

        let samples = [
            Animal(earNumber: "RUBY", name: "3C Ruby", breed: "Mini Rex", color: "Otter - Black", sex: .doe, dateOfBirth: ISO8601DateFormatter().date(from: "2025-05-22T00:00:00Z")),
            Animal(earNumber: "ROLO", name: "Running D's Rolo", breed: "Mini Rex", color: "Otter - Black", sex: .buck, dateOfBirth: ISO8601DateFormatter().date(from: "2022-06-08T00:00:00Z")),
            Animal(earNumber: "PHB1", name: "Scotcha PHB1", breed: "Mini Rex", color: "Broken Otter - Black", sex: .buck, dateOfBirth: ISO8601DateFormatter().date(from: "2021-10-01T00:00:00Z")),
            Animal(earNumber: "FIJI", name: "Cross B Fiji", breed: "Mini Rex", color: "Otter - Black", sex: .doe, dateOfBirth: ISO8601DateFormatter().date(from: "2020-10-22T00:00:00Z"))
        ]

        for animal in samples {
            modelContext.insert(animal)
        }

        try? modelContext.save()
    }
}
