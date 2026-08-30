//
//  SearchBar.swift
//  LoomMusic
//

import SwiftUI

struct SearchBar: View {
    @Binding var query: String
    var onSubmit: () -> Void = {}
    var onClear: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.loomTextSecondary)

            TextField("Search songs, artists, or paste a link...", text: $query)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .onSubmit(onSubmit)

            if !query.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.loomTextSecondary)
                }
                .buttonStyle(.plain)
            }

            Button(action: onSubmit) {
                Text("Enter")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.loomBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
            }
            .buttonStyle(.plain)
            .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
}

#Preview {
    SearchBar(query: .constant(""))
        .padding()
        .background(Color.loomBackground)
}
