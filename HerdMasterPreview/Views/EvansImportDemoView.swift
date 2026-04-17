import SwiftUI

struct EvansImportDemoView: View {
    @State private var document: EvansPedigreeDocument?
    @State private var parseError: String?
    @State private var isProcessing: Bool = false

    var body: some View {
        ZStack {
            HMColor.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HMSpace.lg) {
                    headerBlock

                    PrimaryButton(
                        title: isProcessing ? "Parsing..." : "Parse Sample HTM",
                        action: parseSample,
                        icon: "doc.text.magnifyingglass"
                    )
                    .disabled(isProcessing)

                    if let error = parseError {
                        errorCard(error)
                    }

                    if let document = document {
                        documentSummary(document)
                        animalList(document.animals)
                    }
                }
                .padding(HMSpace.lg)
            }
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: HMSpace.sm) {
            Text("Evans HTM Import")
                .font(HMFont.heading())
                .foregroundStyle(HMColor.textPrimary)

            Text("Parses real Evans Rabbit Register exports. Try it against the included 3C Rabbitry sample.")
                .font(HMFont.body())
                .foregroundStyle(HMColor.textSecondary)
        }
    }

    private func errorCard(_ error: String) -> some View {
        HStack(spacing: HMSpace.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(HMColor.danger)

            Text(error)
                .font(HMFont.caption())
                .foregroundStyle(HMColor.textPrimary)
        }
        .padding(HMSpace.md)
        .background(HMColor.danger.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
    }

    private func documentSummary(_ doc: EvansPedigreeDocument) -> some View {
        VStack(alignment: .leading, spacing: HMSpace.sm) {
            HStack(spacing: HMSpace.md) {
                summaryRow(label: "Rabbitry", value: doc.rabbitryName ?? "Unknown")
                summaryRow(label: "Breed", value: doc.breed ?? "Unknown")
            }

            if let variant = doc.exportVariant {
                summaryRow(label: "Export", value: variant)
            }

            if let owner = doc.ownerName {
                summaryRow(label: "Owner", value: owner)
            }

            if let email = doc.ownerEmail {
                summaryRow(label: "Email", value: email)
            }

            summaryRow(label: "Animals parsed", value: "\(doc.animals.count)")
        }
        .padding(HMSpace.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HMColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
    }

    private func summaryRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(HMFont.micro())
                .foregroundStyle(HMColor.textMuted)
            Text(value)
                .font(HMFont.captionStrong())
                .foregroundStyle(HMColor.textPrimary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func animalList(_ animals: [EvansAnimal]) -> some View {
        VStack(alignment: .leading, spacing: HMSpace.sm) {
            Text("Parsed Animals")
                .font(HMFont.title())
                .foregroundStyle(HMColor.textPrimary)

            ForEach(Array(animals.enumerated()), id: \.offset) { _, animal in
                parsedAnimalCard(animal)
            }
        }
    }

    private func parsedAnimalCard(_ animal: EvansAnimal) -> some View {
        HStack(spacing: HMSpace.md) {
            AnimalAvatar(sex: animal.sex)

            VStack(alignment: .leading, spacing: 2) {
                Text(animal.name)
                    .font(HMFont.bodyStrong())
                    .foregroundStyle(HMColor.textPrimary)

                if let color = animal.color {
                    Text(color)
                        .font(HMFont.caption())
                        .foregroundStyle(HMColor.textSecondary)
                }

                HStack(spacing: HMSpace.sm) {
                    if let ear = animal.earNumber {
                        Text("Ear: \(ear)")
                    }
                    if let weight = animal.weightOunces {
                        Text("Wt: \(formatWeight(weight))")
                    }
                    if let dob = animal.dateOfBirth {
                        Text("DOB: \(dob.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(HMColor.textMuted)
            }

            Spacer()

            Text("Col \(animal.gridColumn)")
                .font(HMFont.micro())
                .foregroundStyle(HMColor.textMuted)
        }
        .padding(HMSpace.md)
        .background(HMColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
    }

    private func formatWeight(_ ounces: Int) -> String {
        let pounds = ounces / 16
        let oz = ounces % 16
        return oz > 0 ? "\(pounds) lb \(oz) oz" : "\(pounds) lb"
    }

    private func parseSample() {
        guard let url = Bundle.main.url(forResource: "evans-sample", withExtension: "htm") else {
            parseError = "Sample file not in bundle. Add Samples/evans-sample.htm to the target."
            return
        }

        isProcessing = true
        parseError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let parser = EvansHTMParser()
            do {
                let doc = try parser.parse(fileAt: url)
                DispatchQueue.main.async {
                    self.document = doc
                    self.isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.parseError = "Parse failed: \(error)"
                    self.isProcessing = false
                }
            }
        }
    }
}
