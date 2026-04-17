#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String?

    var body: some View {
        Button(action: action) {
            HStack(spacing: HMSpace.sm) {
                Text(title)
                    .font(HMFont.title())
                if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .foregroundStyle(HMColor.background)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(HMColor.accent)
            .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(HMFont.title())
                .foregroundStyle(HMColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(HMColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: HMRadius.md)
                        .stroke(HMColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
        }
    }
}
#endif
