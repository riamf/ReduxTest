import Foundation

struct FiltersSceneState: SceneState {

    var children: [SceneState] = []
    var presentingScene: SceneState?
    var coordinatorType: Coordinator.Type {
        return FiltersCoordinator.self
    }
    var preselected: FiltersState = FiltersState.default
    
    init(state: SceneState?, action: Action) { }
    init(state: SceneState?, action: Action, preselected: FiltersState) {
        self.preselected = preselected
    }
    
    mutating func mutate(with action: Action) {
        if let action = action as? ChangeFilter {
            preselected = action.filterState
        }
    }
}
