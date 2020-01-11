import Foundation

struct TabBarSceneState: SceneState {

    var children: [SceneState] = []
    var presentingScene: SceneState?
    let selectedIndex: Int = 0
    var coordinatorType: Coordinator.Type {
        return TabBarControllerCoordinator.self
    }
    
    init(state: SceneState?, action: Action) {
        if let _ = action as? TakeOffAction {
            
        }
    }
    
    mutating func mutate(with action: Action) {}
}
