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
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(tint.opacity(colorScheme == .dark ? 0.18 : 0.11))
                        }
                    }
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(tint.opacity(colorScheme == .dark ? 0.18 : 0.14), lineWidth: 1)
                        }
                    }
            )
            .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 8)
    }
}
