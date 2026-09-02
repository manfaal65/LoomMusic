//
//  HeaderBar.swift
//  LoomMusic
//

import SwiftUI

struct HeaderBar: View {
    @Binding var selectedTab: NavTab
    var onUpgradeTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer().frame(width: Theme.trafficLightInset)

                Text("LoomMusic")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Spacer().frame(width: 48)

                NavTabBar(selectedTab: $selectedTab)

                Spacer()

                HStack(spacing: 16) {
                    UpgradeButton(action: onUpgradeTap)
                    IconButton(symbolName: "gearshape")
                    IconButton(symbolName: "person.crop.circle")
                }
            }
            .padding(.horizontal, 20)
            .frame(height: Theme.headerHeight)

            Rectangle()
                .fill(Color.loomDivider)
                .frame(height: 1)
        }
        .background(
            WindowAccessor { window in
                window.titlebarAppearsTransparent = true
                window.appearance = NSAppearance(named: .darkAqua)
            }
        )
        .background(Color.loomBackground)
    }
}

#Preview {
    HeaderBar(selectedTab: .constant(.home))
        .background(Color.loomBackground)
}
