//
//  NavTabButton.swift
//  LoomMusic
//

import SwiftUI

struct NavTabButton: View {
    let tab: NavTab
    let isSelected: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(tab.rawValue)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? .white : Color.loomTextSecondary)
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.loomAccentPink)
                        .frame(height: 2)
                        .opacity(isSelected ? 1 : 0)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 28) {
        NavTabButton(tab: .home, isSelected: true)
        NavTabButton(tab: .lyricsHub, isSelected: false)
    }
    .padding()
    .background(Color.loomBackground)
}
