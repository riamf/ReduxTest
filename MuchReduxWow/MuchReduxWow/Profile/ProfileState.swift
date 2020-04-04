import Foundation

struct ProfileState: SceneState {
    var children: [SceneState] = []
    var presentingScene: SceneState?
    var coordinatorType: Coordinator.Type {
        return ProfileCoordinator.self
    }

    init(state: SceneState?, action: Action) {

    }
}
