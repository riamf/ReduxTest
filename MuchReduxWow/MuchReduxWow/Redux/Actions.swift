import Foundation

protocol Action {}
struct TakeOffAction: Action {}
struct SearchAction: Action {
    let filter: FiltersState
}

struct NewDataAction: Action {
    let items: Items
    let filter: FiltersState
}

struct PopAction: Action {
    let userInfo: [String: Any]
}

struct PresentAction: Action {
    let userInfo: [String: Any]
}
struct DismissAction: Action {
    let userInfo: [String: Any]
}
