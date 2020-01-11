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
    
    mutating func mutate(with action: Action) {
        if let action = action as? NewDataAction {
            children.append(SearchResultsState(state: nil, action: action))
        }
    }
}
