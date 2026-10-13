//
//  NavTabBar.swift
//  LoomMusic
//

import SwiftUI

struct NavTabBar: View {
    @Binding var selectedTab: NavTab

    var body: some View {
        HStack(spacing: 28) {
            ForEach(NavTab.visibleTabs) { tab in
                NavTabButton(tab: tab, isSelected: tab == selectedTab) {
                    selectedTab = tab
                }
            }
        }
    }
}

#Preview {
    NavTabBar(selectedTab: .constant(.home))
        .padding()
        .background(Color.loomBackground)
}
