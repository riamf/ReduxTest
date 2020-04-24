import Foundation

struct HomeState: SceneState {
    var children: [SceneState] = []
    
    var presentingScene: SceneState?
    
    var coordinatorType: Coordinator.Type {
        return HomeCoordinator.self
    }
    
    init(state: SceneState?, action: Action) {
        
    }
}
