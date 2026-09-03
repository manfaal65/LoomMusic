//
//  HeaderBar.swift
//  LoomMusic
//

import SwiftUI

struct HeaderBar: View {
    @Binding var selectedTab: NavTab

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer().frame(width: Theme.trafficLightInset)

                Text("YuTunes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Spacer().frame(width: 48)

                NavTabBar(selectedTab: $selectedTab)

                Spacer()
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
