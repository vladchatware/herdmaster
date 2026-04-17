#if canImport(SwiftUI) && canImport(SwiftData)
import Foundation
import StoreKit

enum ARBATier: String, CaseIterable {
    case free = "com.herdmaster.free"
    case breeder = "com.herdmaster.breeder"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .breeder: return "Breeder"
        }
    }

    var includesPDFExport: Bool { self == .breeder }
    var animalLimit: Int? {
        switch self {
        case .free: return 10
        case .breeder: return nil
        }
    }
}

@MainActor
final class StoreKit2Manager: ObservableObject {
    static let shared = StoreKit2Manager()

    @Published private(set) var currentTier: ARBATier = .free
    @Published private(set) var availableProducts: [Product] = []

    private var transactionListenerTask: Task<Void, Never>?

    private init() {
        transactionListenerTask = listenForTransactions()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    func loadProducts() async {
        let identifiers = ARBATier.allCases.filter { $0 != .free }.map { $0.rawValue }
        do {
            let products = try await Product.products(for: identifiers)
            availableProducts = products
        } catch {
            print("StoreKit product load failed: \(error)")
        }

        await updateCurrentTier()
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateCurrentTier()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKit2Error.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updateCurrentTier()
                }
            }
        }
    }

    private func updateCurrentTier() async {
        var resolvedTier: ARBATier = .free

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               let tier = ARBATier(rawValue: transaction.productID) {
                if tier == .breeder { resolvedTier = .breeder }
            }
        }

        currentTier = resolvedTier
    }
}

enum StoreKit2Error: Error {
    case unverifiedTransaction
}
#endif
