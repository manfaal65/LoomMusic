//
//  StoreKitService.swift
//  LoomMusic
//

import Combine
import StoreKit

enum StoreKitServiceError: Error {
    case failedVerification
    case productUnavailable
}

enum PurchaseOutcome {
    case success
    case pending
    case cancelled
}

/// Loads the app's subscription products, runs the purchase flow, and tracks
/// which of them the current user has an active entitlement for. Resolves
/// against App Store Connect once real "premium.*" subscriptions exist there
/// with matching product IDs — until then, against the local
/// `Configuration.storekit` file when the scheme is pointed at it.
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []

    private var transactionListener: Task<Void, Never>?

    var isPremiumActive: Bool {
        !purchasedProductIDs.isDisjoint(with: PaywallPlan.allCases.map(\.productID))
    }

    private init() {
        transactionListener = listenForTransactionUpdates()
        Task { await refreshEntitlements() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let ids = PaywallPlan.allCases.map(\.productID)
            let loaded = try await Product.products(for: ids)
            products = PaywallPlan.allCases.compactMap { plan in
                loaded.first { $0.id == plan.productID }
            }
        } catch {
            // Leave `products` empty — PaywallView falls back to the static
            // plan copy until a load succeeds (e.g. on retry or once App
            // Store Connect products exist).
        }
    }

    @discardableResult
    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            let transaction = try Self.checkVerified(verification)
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()
            return .success
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var active: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? Self.checkVerified(result) else { continue }
            if transaction.revocationDate == nil {
                active.insert(transaction.productID)
            }
        }
        purchasedProductIDs = active
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self, let transaction = try? Self.checkVerified(result) else { continue }
                await self.refreshEntitlements()
                await transaction.finish()
            }
        }
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitServiceError.failedVerification
        case let .verified(safe):
            return safe
        }
    }
}
