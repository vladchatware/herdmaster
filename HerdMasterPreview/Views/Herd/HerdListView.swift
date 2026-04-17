import SwiftUI
import SwiftData

struct HerdListView: View {
    @Query(sort: \Animal.createdAt, order: .reverse) private var animals: [Animal]

    @State private var searchText: String = ""
    @State private var selectedFilter: FilterOption = .all

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case archived = "Archived"
        case sold = "Sold"
    }

    var filteredAnimals: [Animal] {
        animals.filter { animal in
            let matchesSearch = searchText.isEmpty
                || (animal.name ?? "").localizedCaseInsensitiveContains(searchText)
                || animal.earNumber.localizedCaseInsensitiveContains(searchText)
                || (animal.breed ?? "").localizedCaseInsensitiveContains(searchText)

            let matchesFilter: Bool = {
                switch selectedFilter {
                case .all: return true
                case .active: return animal.status == .active
                case .archived: return animal.status == .inactive || animal.status == .deceased
                case .sold: return animal.status == .sold
                }
            }()

            return matchesSearch && matchesFilter
        }
    }

    var body: some View {
        ZStack {
            HMColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                filterTabs
                searchBar
                animalList
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hip Rabbitry")
                    .font(HMFont.heading())
                    .foregroundStyle(HMColor.textPrimary)

                Text("\(animals.count) active rabbits")
                    .font(HMFont.caption())
                    .foregroundStyle(HMColor.textSecondary)
            }

            Spacer()

            Button(action: {}) {
                Circle()
                    .fill(HMColor.accent)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "plus")
                            .foregroundStyle(HMColor.background)
                            .font(.system(size: 20, weight: .bold))
                    )
            }
        }
        .padding(HMSpace.lg)
    }

    private var searchBar: some View {
        HStack(spacing: HMSpace.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(HMColor.textMuted)
                .font(.system(size: 16, weight: .medium))

            TextField("", text: $searchText, prompt:
                Text("Search by name, ear #, or breed")
                    .foregroundStyle(HMColor.textMuted)
            )
            .foregroundStyle(HMColor.textPrimary)
        }
        .padding(.horizontal, HMSpace.md)
        .frame(height: 44)
        .background(HMColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
        .padding(.horizontal, HMSpace.lg)
    }

    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(FilterOption.allCases, id: \.self) { filter in
                Button(action: { selectedFilter = filter }) {
                    Text(filter.rawValue)
                        .font(HMFont.captionStrong())
                        .foregroundStyle(selectedFilter == filter ? HMColor.accent : HMColor.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HMSpace.sm)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(selectedFilter == filter ? HMColor.accent : Color.clear)
                                .frame(height: 2)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HMSpace.lg)
        .padding(.top, HMSpace.xs)
    }

    private var animalList: some View {
        ScrollView {
            LazyVStack(spacing: HMSpace.sm) {
                ForEach(filteredAnimals) { animal in
                    AnimalCard(animal: animal)
                }
            }
            .padding(.horizontal, HMSpace.lg)
            .padding(.top, HMSpace.md)
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    HerdListView()
        .modelContainer(for: Animal.self, inMemory: true)
}
