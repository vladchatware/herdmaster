import SwiftUI

struct AnimalCard: View {
    let animal: Animal
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: HMSpace.md) {
                AnimalAvatar(sex: animal.sex)

                VStack(alignment: .leading, spacing: HMSpace.xs) {
                    HStack(spacing: HMSpace.sm) {
                        Text(animal.name ?? animal.earNumber)
                            .font(HMFont.bodyStrong())
                            .foregroundStyle(HMColor.textPrimary)
                            .lineLimit(1)

                        StatusBadge(status: animal.status)
                    }

                    HStack(spacing: HMSpace.sm) {
                        if let breed = animal.breed {
                            Text(breed)
                                .font(HMFont.caption())
                                .foregroundStyle(HMColor.textSecondary)
                        }

                        if let color = animal.color {
                            Text("·")
                                .foregroundStyle(HMColor.textMuted)
                            Text(color)
                                .font(HMFont.caption())
                                .foregroundStyle(HMColor.textSecondary)
                        }
                    }

                    if let dob = animal.dateOfBirth {
                        Text("Born \(dob.formatted(date: .abbreviated, time: .omitted))")
                            .font(HMFont.caption())
                            .foregroundStyle(HMColor.textMuted)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(HMColor.textMuted)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(HMSpace.md)
            .background(HMColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
        }
        .buttonStyle(.plain)
    }
}

struct AnimalAvatar: View {
    let sex: Sex

    var body: some View {
        Circle()
            .fill(backgroundFor(sex))
            .frame(width: 48, height: 48)
            .overlay(
                Image(systemName: iconFor(sex))
                    .foregroundStyle(foregroundFor(sex))
                    .font(.system(size: 20, weight: .medium))
            )
    }

    private func backgroundFor(_ sex: Sex) -> Color {
        switch sex {
        case .buck: return HMColor.Pedigree.male.opacity(0.2)
        case .doe: return HMColor.Pedigree.female.opacity(0.2)
        case .unknown: return HMColor.surfaceElevated
        }
    }

    private func foregroundFor(_ sex: Sex) -> Color {
        switch sex {
        case .buck: return HMColor.Pedigree.male
        case .doe: return HMColor.Pedigree.female
        case .unknown: return HMColor.textMuted
        }
    }

    private func iconFor(_ sex: Sex) -> String {
        switch sex {
        case .buck: return "hare.fill"
        case .doe: return "hare.fill"
        case .unknown: return "questionmark"
        }
    }
}

struct StatusBadge: View {
    let status: AnimalStatus

    var body: some View {
        Text(label)
            .font(HMFont.micro())
            .foregroundStyle(foreground)
            .padding(.horizontal, HMSpace.sm)
            .padding(.vertical, 2)
            .background(background)
            .clipShape(Capsule())
    }

    private var label: String {
        switch status {
        case .active: return "ACTIVE"
        case .inactive: return "INACTIVE"
        case .sold: return "SOLD"
        case .deceased: return "DECEASED"
        }
    }

    private var foreground: Color {
        switch status {
        case .active: return HMColor.success
        case .inactive: return HMColor.textMuted
        case .sold: return HMColor.accent
        case .deceased: return HMColor.danger
        }
    }

    private var background: Color {
        foreground.opacity(0.15)
    }
}
