//
//  PlaceholderScreen.swift
//  LoomMusic
//

import SwiftUI

struct PlaceholderScreen: View {
    let tab: NavTab

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: tab.symbolName)
                .font(.system(size: 40))
                .foregroundStyle(Color.loomTextSecondary)
            Text(tab.rawValue)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Text("Coming soon")
                .font(.system(size: 14))
                .foregroundStyle(Color.loomTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.loomBackground)
    }
}

#Preview {
    PlaceholderScreen(tab: .upload)
}
