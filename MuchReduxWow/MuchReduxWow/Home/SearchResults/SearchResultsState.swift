import Foundation

struct SearchResultsState: SceneState {
    var items: Items?
    var children: [SceneState] = []
    var presentingScene: SceneState?
    var coordinatorType: Coordinator.Type {
        return SearchResultsCoordinator.self
    }
    
    init(state: SceneState?, action: Action) {
        if let action = action as? NewDataAction {
            self.items = action.items
        }
    }
}
