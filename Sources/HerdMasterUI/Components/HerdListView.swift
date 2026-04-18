import SwiftUI
import SwiftData

struct HerdListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Animal.earNumber) private var animals: [Animal]

    var body: some View {
        NavigationStack {
            List(animals) { animal in
                AnimalCard(animal: animal)
            }
            .navigationTitle("Herd")
        }
    }
}