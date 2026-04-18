import SwiftUI

struct PedigreeDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 60))
            Text("Pedigree View")
                .font(.title)
        }
        .padding()
    }
}