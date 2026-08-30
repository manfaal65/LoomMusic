//
//  IconButton.swift
//  LoomMusic
//

import SwiftUI

struct IconButton: View {
    let symbolName: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.loomTextSecondary)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

#Preview {
    HStack {
        IconButton(symbolName: "gearshape")
        IconButton(symbolName: "person.crop.circle")
    }
    .padding()
    .background(Color.loomBackground)
}
