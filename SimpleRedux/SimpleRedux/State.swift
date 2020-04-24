import Foundation

public protocol Reducable {
    static func reduce(_ action: Action, _ state: Self, _ hasChanged: inout Bool) -> Self
}

public extension Reducable {
    static func reduce(_ action: Action, _ state: Self, _ hasChanged: inout Bool) -> Self {
        return state
    }
}

public protocol State: Reducable { }
