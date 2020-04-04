import Foundation

enum Order: String {
    case asc
    case desc
}

struct FiltersState: Equatable {
    var order: Order = .asc
    var phrase: String = ""
    var languages: [Language] = []

    static var `default`: FiltersState {
        return FiltersState()
    }
}
