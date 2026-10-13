//
//  SettingsView.swift
//  LoomMusic
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = StoreKitService.shared
    var onOpenPaywall: () -> Void = {}

    @State private var isRestoring = false
    @State private var restoreMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()
                .background(Color.loomDivider)

            ScrollView {
                VStack(spacing: 20) {
                    subscriptionBanner
                    purchasesSection
                    supportSection
                    legalSection
                    aboutSection
                }
                .padding(Theme.contentPadding)
            }
        }
        .frame(width: 580, height: 600)
        .background(Color.loomBackground)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Settings")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text("Manage your preferences and subscription")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.loomTextSecondary)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.contentPadding)
        .padding(.vertical, 16)
    }

    // MARK: - Subscription Banner

    private var subscriptionBanner: some View {
        Group {
            if store.isPremiumActive {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.loomPremiumGold.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.loomPremiumGold)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text("YuTunes Pro")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)

                            Text("ACTIVE")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.loomPremiumGold)
                                .clipShape(Capsule())
                        }
                        Text("You have unlocked all premium music and AI companion features.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.loomTextSecondary)
                    }

                    Spacer()
                }
                .padding(16)
                .background(Color.loomSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(Color.loomPremiumGold.opacity(0.3), lineWidth: 1)
                )
            } else {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.loomAccentBlue.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.loomAccentBlue)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Upgrade to YuTunes Pro")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Unlock unlimited AI lyrics generation, track summaries, and unlimited listening.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.loomTextSecondary)
                    }

                    Spacer()

                    Button(action: {
                        dismiss()
                        onOpenPaywall()
                    }) {
                        Text("Upgrade")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.loomAccentBlue)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(Color.loomSurface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(Color.loomAccentBlue.opacity(0.3), lineWidth: 1)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                    onOpenPaywall()
                }
            }
        }
    }

    // MARK: - Purchases Section

    private var purchasesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SUBSCRIPTION & PURCHASES")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.loomTextSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Restore Purchases")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                        Text("Restore previous purchases and subscriptions made on this Apple ID")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.loomTextSecondary)
                    }

                    Spacer()

                    if isRestoring {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Button(action: restorePurchases) {
                            Text("Restore")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.loomAccentBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.loomAccentBlue.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(14)

                if let message = restoreMessage {
                    Divider()
                        .background(Color.loomDivider)
                    HStack {
                        Image(systemName: store.isPremiumActive ? "checkmark.circle.fill" : "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(store.isPremiumActive ? Color.green : Color.loomTextSecondary)
                        Text(message)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.loomTextSecondary)
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(Color.loomDivider, lineWidth: 1)
            )
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SUPPORT & CONTACT")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.loomTextSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingRow(
                    icon: "envelope.fill",
                    title: "Contact Us",
                    subtitle: "aamir.soh87@gmail.com",
                    trailingIcon: "arrow.up.right"
                ) {
                    contactSupport()
                }
            }
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(Color.loomDivider, lineWidth: 1)
            )
        }
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LEGAL & POLICIES")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.loomTextSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                settingRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    subtitle: "Read how your personal data and audio files are protected",
                    trailingIcon: "arrow.up.right"
                ) {
                    if let url = URL(string: "https://sites.google.com/view/aamirsohail/privacy-policy") {
                        NSWorkspace.shared.open(url)
                    }
                }

                Divider()
                    .background(Color.loomDivider)
                    .padding(.leading, 44)

                settingRow(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    subtitle: "Review the terms and conditions for using YuTUNES",
                    trailingIcon: "arrow.up.right"
                ) {
                    if let url = URL(string: "https://sites.google.com/view/aamirsohail/terms-of-use") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(Color.loomDivider, lineWidth: 1)
            )
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ABOUT")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.loomTextSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.loomAccentBlue.opacity(0.16))
                            .frame(width: 32, height: 32)
                        Image(systemName: "music.note")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.loomAccentBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("YuTUNES")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Version \(appVersion)")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.loomTextSecondary)
                    }

                    Spacer()
                }
                .padding(14)
            }
            .background(Color.loomSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(Color.loomDivider, lineWidth: 1)
            )
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // MARK: - Helpers

    private func settingRow(
        icon: String,
        title: String,
        subtitle: String,
        trailingIcon: String = "chevron.right",
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.loomTextSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.loomTextSecondary)
                }

                Spacer()

                Image(systemName: trailingIcon)
                    .font(.system(size: trailingIcon == "chevron.right" ? 11 : 12, weight: .semibold))
                    .foregroundStyle(Color.loomTextSecondary.opacity(0.5))
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func restorePurchases() {
        isRestoring = true
        restoreMessage = nil
        Task {
            do {
                try await store.restorePurchases()
                isRestoring = false
                if store.isPremiumActive {
                    restoreMessage = "Purchases restored successfully! YuTunes Pro is active."
                } else {
                    restoreMessage = "No active subscriptions found for this Apple ID."
                }
            } catch {
                isRestoring = false
                restoreMessage = "Unable to restore purchases. Please try again."
            }
        }
    }

    private func contactSupport() {
        let email = "aamir.soh87@gmail.com"
        let subject = "YuTUNES Support Request"
        let body = "Hi YuTUNES Team,\n\nI need help with:\n"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let mailtoURL = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            NSWorkspace.shared.open(mailtoURL)
        }
    }
}

#Preview {
    SettingsView()
}
