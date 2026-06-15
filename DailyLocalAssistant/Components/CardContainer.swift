import SwiftUI

struct CardContainer<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    var tint: Color?
    var content: Content

    init(tint: Color? = nil, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(DesignSystem.Padding.card)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.large, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.large, style: .continuous)
                                .fill(tint.opacity(colorScheme == .dark ? 0.18 : 0.11))
                        }
                    }
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.large, style: .continuous)
                                .stroke(tint.opacity(colorScheme == .dark ? 0.18 : 0.14), lineWidth: 1)
                        }
                    }
            )
            .shadow(color: DesignSystem.Shadow.softColor, radius: DesignSystem.Shadow.softRadius, x: 0, y: DesignSystem.Shadow.softY)
    }
}
