import SwiftUI

struct EvansImportDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 60))
            Text("Import Evans Pedigrees")
                .font(.title)
        }
        .padding()
    }
}