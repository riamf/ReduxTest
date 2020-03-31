import Foundation

struct ProfileNavigationState: SceneState {
    var children: [SceneState] = []
    var presentingScene: SceneState?
    var coordinatorType: Coordinator.Type {
        return ProfileNavigationCoordinator.self
    }
    
    init(state: SceneState?, action: Action) {
        if let _ = action as? TakeOffAction {
            children = [
                ProfileState(state: state, action: action)
            ]
        }
    }
}
