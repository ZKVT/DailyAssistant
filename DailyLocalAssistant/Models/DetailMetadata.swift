import Foundation

struct DetailMetadata: Identifiable, Hashable {
    let label: String
    let value: String

    var id: String {
        label
    }
}
