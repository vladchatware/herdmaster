import SwiftUI

struct PedigreeCell: View {
    let name: String?
    let color: String?
    let earNumber: String?
    let dob: Date?
    let sex: Sex
    var isPlaceholder: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: HMSpace.xxs) {
            if isPlaceholder {
                Text("Unknown")
                    .font(HMFont.captionStrong())
                    .foregroundStyle(HMColor.textMuted)
                    .italic()
            } else {
                Text(name ?? "—")
                    .font(HMFont.captionStrong())
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                if let color = color {
                    Text(color)
                        .font(.system(size: 10))
                        .foregroundStyle(textColor.opacity(0.8))
                        .lineLimit(1)
                }

                if let ear = earNumber, !ear.isEmpty {
                    Text("Ear: \(ear)")
                        .font(.system(size: 9))
                        .foregroundStyle(textColor.opacity(0.7))
                }

                if let dob = dob {
                    Text(dob.formatted(.dateTime.year()))
                        .font(.system(size: 9))
                        .foregroundStyle(textColor.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, HMSpace.sm)
        .padding(.vertical, HMSpace.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(borderColor, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var backgroundColor: Color {
        if isPlaceholder { return HMColor.Pedigree.neuterSurface }
        switch sex {
        case .buck: return HMColor.Pedigree.maleSurface
        case .doe: return HMColor.Pedigree.femaleSurface
        case .unknown: return HMColor.Pedigree.neuterSurface
        }
    }

    private var borderColor: Color {
        if isPlaceholder { return HMColor.Pedigree.neuter }
        switch sex {
        case .buck: return HMColor.Pedigree.male
        case .doe: return HMColor.Pedigree.female
        case .unknown: return HMColor.Pedigree.neuter
        }
    }

    private var textColor: Color {
        Color(hex: 0x1E293B)
    }
}
