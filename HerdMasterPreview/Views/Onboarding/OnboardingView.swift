import SwiftUI

struct OnboardingView: View {
    @State private var selectedPath: BreederPath?

    enum BreederPath {
        case arba
        case independent
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [HMColor.background, HMColor.surface],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: HMSpace.xl) {
                Spacer().frame(height: HMSpace.xxl)

                Image(systemName: "hare.fill")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(HMColor.accent)
                    .padding(HMSpace.xl)
                    .background(
                        Circle()
                            .fill(HMColor.accent.opacity(0.15))
                    )

                VStack(spacing: HMSpace.sm) {
                    Text("Head Master")
                        .font(HMFont.displayLarge())
                        .foregroundStyle(HMColor.textPrimary)

                    Text("Professional rabbit herd management\nfor breeders")
                        .font(HMFont.body())
                        .foregroundStyle(HMColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(spacing: HMSpace.md) {
                    Text("Choose Your Path")
                        .font(HMFont.title())
                        .foregroundStyle(HMColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    PathCard(
                        title: "ARBA Member",
                        subtitle: "30-day Breeder trial included",
                        icon: "rosette",
                        isSelected: selectedPath == .arba
                    ) {
                        selectedPath = .arba
                    }

                    PathCard(
                        title: "Independent Breeder",
                        subtitle: "14-day trial, full features",
                        icon: "person.fill",
                        isSelected: selectedPath == .independent
                    ) {
                        selectedPath = .independent
                    }
                }
                .padding(.horizontal, HMSpace.lg)

                PrimaryButton(title: "Continue", action: {}, icon: "arrow.right")
                    .padding(.horizontal, HMSpace.lg)
                    .disabled(selectedPath == nil)
                    .opacity(selectedPath == nil ? 0.5 : 1.0)

                Spacer().frame(height: HMSpace.lg)
            }
        }
    }
}

struct PathCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HMSpace.md) {
                Circle()
                    .fill(isSelected ? HMColor.accent.opacity(0.2) : HMColor.surfaceElevated)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundStyle(isSelected ? HMColor.accent : HMColor.textMuted)
                            .font(.system(size: 18, weight: .medium))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(HMFont.bodyStrong())
                        .foregroundStyle(HMColor.textPrimary)

                    Text(subtitle)
                        .font(HMFont.caption())
                        .foregroundStyle(HMColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(isSelected ? HMColor.accent : HMColor.textMuted)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(HMSpace.md)
            .background(isSelected ? HMColor.surface : HMColor.surface.opacity(0.6))
            .overlay(
                RoundedRectangle(cornerRadius: HMRadius.md)
                    .stroke(isSelected ? HMColor.accent : HMColor.divider, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HMRadius.md))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
}
