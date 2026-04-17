import SwiftUI

struct PedigreeDemoView: View {
    @State private var document: EvansPedigreeDocument?

    var body: some View {
        ZStack {
            HMColor.background.ignoresSafeArea()

            if let doc = document, let subject = doc.subject {
                PedigreeGridView(
                    subject: subject,
                    ancestors: doc.animals.filter { $0.gridColumn > 0 },
                    breed: doc.breed,
                    rabbitryName: doc.rabbitryName
                )
            } else {
                loadingView
            }
        }
        .onAppear(perform: loadSample)
    }

    private var loadingView: some View {
        VStack(spacing: HMSpace.md) {
            ProgressView()
                .tint(HMColor.accent)

            Text("Loading pedigree from Evans sample...")
                .font(HMFont.body())
                .foregroundStyle(HMColor.textSecondary)
        }
    }

    private func loadSample() {
        guard document == nil,
              let url = Bundle.main.url(forResource: "evans-sample", withExtension: "htm") else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let parser = EvansHTMParser()
            let doc = try? parser.parse(fileAt: url)
            DispatchQueue.main.async {
                self.document = doc
            }
        }
    }
}
