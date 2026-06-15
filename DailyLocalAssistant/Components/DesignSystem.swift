import SwiftUI

enum DesignSystem {
    enum Spacing {
        static let xSmall: CGFloat = 6
        static let small: CGFloat = 10
        static let medium: CGFloat = 14
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 28
    }

    enum Radius {
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 30
    }

    enum Padding {
        static let card: CGFloat = 18
        static let screenHorizontal: CGFloat = 20
    }

    enum Shadow {
        static let softColor = Color.black.opacity(0.07)
        static let softRadius: CGFloat = 18
        static let softY: CGFloat = 8
    }

    enum Gradient {
        static let morning = LinearGradient(
            colors: [Color.blue.opacity(0.55), Color.teal.opacity(0.32), Color.orange.opacity(0.18)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let explore = LinearGradient(
            colors: [Color.green.opacity(0.48), Color.blue.opacity(0.24), Color.purple.opacity(0.18)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
