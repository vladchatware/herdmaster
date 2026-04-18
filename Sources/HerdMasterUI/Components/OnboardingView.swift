import SwiftUI

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
            Text("Welcome to HerdMaster")
                .font(.title)
        }
        .padding()
    }
}