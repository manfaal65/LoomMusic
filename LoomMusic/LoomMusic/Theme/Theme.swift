//
//  Theme.swift
//  LoomMusic
//

import SwiftUI

enum Theme {
    static let headerHeight: CGFloat = 58
    static let trafficLightInset: CGFloat = 78
    static let contentPadding: CGFloat = 24

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let card: CGFloat = 14
        static let pill: CGFloat = 999
    }

    static let accentGradient = LinearGradient(
        colors: [.loomAccentStart, .loomAccentEnd],
        startPoint: .leading,
        endPoint: .trailing
    )
}
