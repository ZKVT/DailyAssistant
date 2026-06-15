import SwiftUI

struct LoadingStateView: View {
    var title: String = "Loading today"
    var message: String = "Preparing your local recommendations."

    var body: some View {
        CardContainer(tint: .blue) {
            VStack(alignment: .center, spacing: 14) {
                ProgressView()
                    .controlSize(.large)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
        }
    }
}
