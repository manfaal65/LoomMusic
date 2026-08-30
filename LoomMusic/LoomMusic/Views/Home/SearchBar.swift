//
//  SearchBar.swift
//  LoomMusic
//

import SwiftUI

struct SearchBar: View {
    @State private var query: String = ""

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.loomTextSecondary)

            TextField("Search songs, artists, or paste a link...", text: $query)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .font(.system(size: 14))

            Button(action: submit) {
                Text("Enter")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.loomBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.loomSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.pill)
                .stroke(Color.loomDivider, lineWidth: 1)
        )
    }

    private func submit() {
        // No search backend yet.
    }
}

#Preview {
    SearchBar()
        .padding()
        .background(Color.loomBackground)
}
