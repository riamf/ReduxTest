import Foundation

struct HomeNavigationState: SceneState {
    var children: [SceneState] = []
    
    var presentingScene: SceneState?
    
    var coordinatorType: Coordinator.Type {
        return HomeNavigationCoordinator.self
    }
    
    init(state: SceneState?, action: Action) {
        if let _ = action as? TakeOffAction {
            children = [
                 HomeState(state: state, action: action)
            ]
        }
    }
}
