//
//  PaywallPlan.swift
//  LoomMusic
//

import Foundation

enum PaywallPlan: String, CaseIterable, Identifiable {
    case monthly
    case yearly
    case lifetime

    var id: String { rawValue }

    /// App Store Connect product identifier for this plan. Monthly/yearly are
    /// auto-renewable subscriptions in one "Premium" group; lifetime is a
    /// separate non-consumable one-time purchase. These match what's registered
    /// (or will be registered) in App Store Connect; until then they resolve
    /// against the local `Configuration.storekit` file instead.
    var productID: String {
        switch self {
        case .monthly: return "music_monthly"
        case .yearly: return "music_yearly"
        case .lifetime: return "music_lifetime"
        }
    }

    /// Whether this plan is a recurring subscription vs. a one-time purchase —
    /// drives trial/renewal copy differences in the paywall UI.
    var isSubscription: Bool { self != .lifetime }

    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    var price: String {
        switch self {
        case .monthly: return "$7.99"
        case .yearly: return "$29.99"
        case .lifetime: return "$79.99"
        }
    }

    var priceUnit: String {
        switch self {
        case .monthly: return "/month"
        case .yearly: return "/year"
        case .lifetime: return ""
        }
    }

    /// Secondary line shown under the price. Monthly has none since it's
    /// already the baseline; yearly compares against monthly; lifetime
    /// clarifies it's a one-time charge, not a subscription.
    var equivalentSubtext: String? {
        switch self {
        case .monthly: return nil
        case .yearly: return "≈ $2.50/mo · Save 69% vs monthly"
        case .lifetime: return "One-time payment · Yours forever"
        }
    }

    var isBestValue: Bool { self == .yearly }

    var pillLabel: String {
        isSubscription ? "3-DAY FREE TRIAL" : "ONE-TIME PURCHASE"
    }

    var ctaTitle: String {
        isSubscription ? "Start 3-Day Free Trial" : "Buy Lifetime Access"
    }

    var trialFinePrint: String {
        isSubscription
            ? "3 days free, then \(price)\(priceUnit). Cancel anytime."
            : "One-time payment of \(price). No recurring charges, ever."
    }
}
