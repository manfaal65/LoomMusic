//
//  SectionHeader.swift
//  LoomMusic
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var trailingTitle: String? = nil
    var trailingAction: () -> Void = {}

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            if let trailingTitle, !trailingTitle.isEmpty {
                Button(action: trailingAction) {
                    HStack(spacing: 4) {
                        Text(trailingTitle)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Color.loomTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    SectionHeader(title: "Recent", trailingTitle: "Show More")
        .padding()
        .background(Color.loomBackground)
}
