//
//  LatticePattern.swift
//  LoomMusic
//

import SwiftUI

/// Gradient-filled placeholder art with a faint diagonal lattice texture,
/// standing in for real album artwork.
struct LatticePattern: View {
    let colors: [Color]

    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Canvas { context, size in
                let spacing: CGFloat = 14
                let stroke = GraphicsContext.Shading.color(.white.opacity(0.10))
                var x: CGFloat = -size.height
                while x < size.width {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                    context.stroke(path, with: stroke, lineWidth: 1)

                    var path2 = Path()
                    path2.move(to: CGPoint(x: x, y: size.height))
                    path2.addLine(to: CGPoint(x: x + size.height, y: 0))
                    context.stroke(path2, with: stroke, lineWidth: 1)

                    x += spacing
                }
            }
        }
    }
}

#Preview {
    LatticePattern(colors: Song.sample[0].artColors)
        .frame(width: 180, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .background(Color.loomBackground)
}
