//
//  SongDetailTabPicker.swift
//  LoomMusic
//

import SwiftUI

enum SongDetailTab: String, CaseIterable {
    case lyrics = "Lyrics"
    case songInfo = "Song Info"
}

struct SongDetailTabPicker: View {
    @Binding var selection: SongDetailTab

    var body: some View {
        HStack(spacing: 2) {
            ForEach(SongDetailTab.allCases, id: \.self) { tab in
                segmentButton(for: tab)
            }
        }
        .padding(3)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small + 3))
    }

    @ViewBuilder
    private func segmentButton(for tab: SongDetailTab) -> some View {
        let isSelected = selection == tab
        Button {
            selection = tab
        } label: {
            Text(tab.rawValue)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : Color.loomTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.loomSurface : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SongDetailTabPicker(selection: .constant(.lyrics))
        .padding()
        .background(Color.loomBackground)
}
