import Foundation

protocol Action {}
struct TakeOffAction: Action {}
struct SearchAction: Action {
    let filter: FiltersState
}

struct NewDataAction: Action {
    let items: Items
}

struct PopAction: Action {
    let userInfo: [String: Any]
}
