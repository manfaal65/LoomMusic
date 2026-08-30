//
//  UpgradeButton.swift
//  LoomMusic
//

import SwiftUI

struct UpgradeButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Upgrade")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.accentGradient)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UpgradeButton()
        .padding()
        .background(Color.loomBackground)
}
