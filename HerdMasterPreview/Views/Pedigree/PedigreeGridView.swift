import SwiftUI

struct PedigreeGridView: View {
    let subject: EvansAnimal
    let ancestors: [EvansAnimal]
    let breed: String?
    let rabbitryName: String?

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(HMSpace.lg)
                .background(HMColor.background)

            ScrollView([.horizontal, .vertical]) {
                pedigreeTable
                    .padding(HMSpace.lg)
            }
            .background(Color(hex: 0xFFFFFA))
        }
    }

    private var header: some View {
        VStack(spacing: HMSpace.xs) {
            Text(rabbitryName ?? "Rabbitry")
                .font(HMFont.displayMedium())
                .foregroundStyle(HMColor.accent)

            if let breed = breed {
                Text("\(breed) Pedigree")
                    .font(HMFont.heading())
                    .foregroundStyle(HMColor.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HMSpace.md)
        .background(Color.black)
        .overlay(
            RoundedRectangle(cornerRadius: HMRadius.sm)
                .stroke(HMColor.accent, lineWidth: 4)
        )
    }

    private var pedigreeTable: some View {
        HStack(alignment: .center, spacing: HMSpace.sm) {
            subjectColumn
            parentsColumn
            grandparentsColumn
            greatGrandparentsColumn
        }
        .frame(minWidth: 600)
    }

    private var subjectColumn: some View {
        VStack {
            Spacer()
            PedigreeCell(
                name: subject.name,
                color: subject.color,
                earNumber: subject.earNumber,
                dob: subject.dateOfBirth,
                sex: subject.sex
            )
            .frame(width: 140)
            Spacer()
        }
    }

    private var parents: [EvansAnimal] {
        ancestors.filter { $0.gridColumn == 1 }
    }

    private var grandparents: [EvansAnimal] {
        ancestors.filter { $0.gridColumn == 2 }
    }

    private var greatGrandparents: [EvansAnimal] {
        ancestors.filter { $0.gridColumn == 3 }
    }

    private var parentsColumn: some View {
        VStack(spacing: HMSpace.xl) {
            ForEach(Array(parents.prefix(2).enumerated()), id: \.offset) { _, animal in
                PedigreeCell(
                    name: animal.name,
                    color: animal.color,
                    earNumber: animal.earNumber,
                    dob: animal.dateOfBirth,
                    sex: animal.sex,
                    isPlaceholder: animal.isPlaceholder
                )
                .frame(width: 140)
            }
        }
    }

    private var grandparentsColumn: some View {
        VStack(spacing: HMSpace.lg) {
            ForEach(Array(grandparents.prefix(4).enumerated()), id: \.offset) { _, animal in
                PedigreeCell(
                    name: animal.name,
                    color: animal.color,
                    earNumber: animal.earNumber,
                    dob: animal.dateOfBirth,
                    sex: animal.sex,
                    isPlaceholder: animal.isPlaceholder
                )
                .frame(width: 140)
            }
        }
    }

    private var greatGrandparentsColumn: some View {
        VStack(spacing: HMSpace.sm) {
            ForEach(Array(greatGrandparents.prefix(8).enumerated()), id: \.offset) { _, animal in
                PedigreeCell(
                    name: animal.name,
                    color: animal.color,
                    earNumber: animal.earNumber,
                    dob: animal.dateOfBirth,
                    sex: animal.sex,
                    isPlaceholder: animal.isPlaceholder
                )
                .frame(width: 140)
            }
        }
    }
}

#Preview {
    PedigreeGridView(
        subject: EvansAnimal(
            name: "3C RUBY",
            sex: .doe,
            color: "Otter - Black",
            earNumber: "RUBY",
            registrationNumber: nil,
            weightOunces: nil,
            grandChampion: nil,
            legs: nil,
            dateOfBirth: nil,
            gridColumn: 0,
            gridRow: 0
        ),
        ancestors: [],
        breed: "Mini Rex",
        rabbitryName: "3C Rabbitry"
    )
}
