//
//  LyricsContentView.swift
//  LoomMusic
//

import SwiftUI

struct LyricsContentView: View {
    let paragraphs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .lineSpacing(10)
            }
        }
    }
}

#Preview {
    ScrollView {
        LyricsContentView(paragraphs: Song.sample[0].lyrics)
            .padding()
    }
    .background(Color.loomBackground)
}
