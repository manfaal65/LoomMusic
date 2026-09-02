//
//  PaywallView.swift
//  LoomMusic
//

import StoreKit
import SwiftUI

private struct PaywallFeature {
    let symbolName: String
    let title: String
    let description: String
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = StoreKitService.shared
    @State private var selectedPlan: PaywallPlan = .yearly
    @State private var isPurchasing = false
    @State private var statusMessage: String?
    @State private var purchaseTask: Task<Void, Never>?

    private let features: [PaywallFeature] = [
        PaywallFeature(symbolName: "speaker.wave.2.fill", title: "Listen without limits", description: "Stream and preview every track in your library with no caps or restrictions."),
        PaywallFeature(symbolName: "wand.and.stars", title: "Generate Your own Lyrics", description: "Turn a mood or idea into an original verse with the AI Lyrics Generator."),
        PaywallFeature(symbolName: "doc.text.magnifyingglass", title: "AI Song Summary", description: "Paste any link and get key themes, structure, and tempo in seconds."),
        PaywallFeature(symbolName: "doc.text.fill", title: "Browse Lyrics", description: "Search the full catalog and read along with every lyric sheet.")
    ]

    private let featureColumns = [GridItem(.flexible(), spacing: 32), GridItem(.flexible(), spacing: 32)]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    header
                    featureGrid
                    planPicker
                    ctaSection
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }

            Divider()
                .background(Color.loomDivider)

            footer
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
        }
        .frame(width: 720)
        .background(Color.loomBackground)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                closeButton
                Spacer()
            }

            (
                Text("Unlock ")
                    .foregroundStyle(.white)
                + Text("Premium")
                    .foregroundStyle(Color.loomAccentBlue)
                + Text(" Features")
                    .foregroundStyle(.white)
            )
            .font(.system(size: 32, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            Text("Generate original lyrics, summarize any track, and read along with the full catalog — all without limits.")
                .font(.system(size: 15))
                .foregroundStyle(Color.loomTextSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 460)
        }
    }

    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.white.opacity(0.12)))
        }
        .buttonStyle(.plain)
    }

    private var featureGrid: some View {
        LazyVGrid(columns: featureColumns, alignment: .leading, spacing: 24) {
            ForEach(features, id: \.title) { feature in
                featureRow(feature)
            }
        }
    }

    private func featureRow(_ feature: PaywallFeature) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: feature.symbolName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.loomAccentBlue)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(feature.description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.loomTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var planPicker: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(PaywallPlan.allCases) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: PaywallPlan) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            selectedPlan = plan
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    pill(for: plan)
                    Spacer()
                    selectionIndicator(isSelected: isSelected)
                }

                Text(plan.title)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.loomTextSecondary)

                if let product = product(for: plan) {
                    Text(product.displayPrice)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    (
                        Text(plan.price)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        + Text(plan.priceUnit)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.loomTextSecondary)
                    )
                }

                // Reserve this line's height on every card, even when a plan has no
                // subtext, so all three cards stay the same size instead of the
                // shorter ones collapsing.
                Text(plan.equivalentSubtext ?? " ")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
                    .opacity(plan.equivalentSubtext == nil ? 0 : 1)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(isSelected ? Color.loomAccentBlue : Color.loomDivider, lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .top) {
                if plan.isBestValue {
                    bestValuePill
                        .offset(y: -12)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func pill(for plan: PaywallPlan) -> some View {
        Text(plan.pillLabel)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Color.loomAccentBlue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.loomAccentBlue.opacity(0.16))
            .clipShape(Capsule())
    }

    private var bestValuePill: some View {
        Text("BEST VALUE")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.loomAccentBlue)
            .clipShape(Capsule())
    }

    private func selectionIndicator(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.loomAccentBlue : Color.clear)
                .overlay(Circle().stroke(isSelected ? Color.clear : Color.loomDivider, lineWidth: 1.5))
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 20, height: 20)
    }

    private var ctaSection: some View {
        VStack(spacing: 10) {
            Button(action: purchase) {
                Group {
                    if isPurchasing {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Text(selectedPlan.ctaTitle)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.loomAccentBlue)
                .clipShape(Capsule())
                .shadow(color: Color.loomAccentBlue.opacity(0.4), radius: 16, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(isPurchasing)

            if let statusMessage {
                Text(statusMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text(selectedPlan.trialFinePrint)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.loomTextSecondary)
            }

            if selectedPlan.isSubscription {
                Text("Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. Manage or cancel anytime in Account Settings.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.loomTextSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 560)
            } else {
                Text("Lifetime access is a single one-time purchase — not a subscription, so there's nothing to renew or cancel.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.loomTextSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 560)
            }
        }
    }

    private var footer: some View {
        HStack {
            Button("Terms of Service") {}
                .buttonStyle(.plain)
                .foregroundStyle(Color.loomAccentBlue)

            Spacer()

            Button("Privacy Policy") {}
                .buttonStyle(.plain)
                .foregroundStyle(Color.loomAccentBlue)

            Spacer()

            HStack(spacing: 4) {
                Text("Already purchased?")
                    .foregroundStyle(Color.loomTextSecondary)
                Button("Restore", action: restore)
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.loomAccentBlue)
                    .disabled(isPurchasing)
            }
        }
        .font(.system(size: 13))
    }

    private func product(for plan: PaywallPlan) -> Product? {
        store.products.first { $0.id == plan.productID }
    }

    private func purchase() {
        guard !isPurchasing else { return }
        guard let product = product(for: selectedPlan) else {
            statusMessage = "This plan isn't available right now. Please try again in a moment."
            return
        }

        statusMessage = nil
        isPurchasing = true

        purchaseTask?.cancel()
        purchaseTask = Task {
            do {
                let outcome = try await store.purchase(product)
                guard !Task.isCancelled else { return }
                switch outcome {
                case .success:
                    dismiss()
                case .pending:
                    statusMessage = "Purchase is awaiting approval. You'll get access once it's confirmed."
                case .cancelled:
                    break
                }
            } catch is CancellationError {
                // Superseded by a newer action — leave state as-is.
            } catch StoreKitServiceError.failedVerification {
                statusMessage = "Couldn't verify this purchase. Please try again."
            } catch {
                statusMessage = "Couldn't complete the purchase. Check your connection and try again."
            }
            isPurchasing = false
        }
    }

    private func restore() {
        guard !isPurchasing else { return }
        statusMessage = nil
        isPurchasing = true

        purchaseTask?.cancel()
        purchaseTask = Task {
            do {
                try await store.restorePurchases()
                guard !Task.isCancelled else { return }
                if store.isPremiumActive {
                    dismiss()
                } else {
                    statusMessage = "No previous purchase found for this account."
                }
            } catch is CancellationError {
            } catch {
                statusMessage = "Couldn't restore purchases. Check your connection and try again."
            }
            isPurchasing = false
        }
    }
}

#Preview {
    Color.loomBackground
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PaywallView()
        }
}
