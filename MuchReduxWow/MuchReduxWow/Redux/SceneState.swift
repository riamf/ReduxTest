import UIKit

protocol SceneState {
    var children: [SceneState] { get set }
    var presentingScene: SceneState? { get }
    var coordinatorType: Coordinator.Type { get }
    init(state: SceneState?, action: Action)
    
    mutating func mutate(with action: Action)
}

extension SceneState {
    func of<T>(of kind: T.Type) -> T? {
        guard type(of: self) == kind else {
            return children.reversed().compactMap({ $0.of(of: kind) }).first
        }
        return self as? T
    }
}

extension SceneState {
    mutating func mutate(with action: Action) {
        for i in (0..<children.count) {
            var tmp = children[i]
            tmp.mutate(with: action)
            children[i] = tmp
        }
    }
}
