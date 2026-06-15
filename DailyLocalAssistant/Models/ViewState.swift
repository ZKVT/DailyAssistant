import Foundation

enum ViewState: Equatable {
    case loading
    case loaded
    case empty
    case error(String)
}
