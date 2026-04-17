import SwiftUI

struct StatTile: View {
    let value: String
    let label: String
    var accent: Color = HMColor.accent
    var trend: String?

    var body: some View {
        VStack(alignment: .leading, spacing: HMSpace.sm) {
            HStack {
                Circle()
                    .fill(accent.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(accent)
                    )

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(HMFont.micro())
                        .foregroundStyle(HMColor.success)
                }
            }

            Text(value)
                .font(HMFont.statLarge())
                .foregroundStyle(HMColor.textPrimary)

            Text(label)
                .font(HMFont.caption())
                .foregroundStyle(HMColor.textSecondary)
        }
        .padding(HMSpace.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HMColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
    }
}
