import UIKit

protocol State {
    var sceneState: SceneState { get set }
}

protocol StateChangeObserver {
    func notify(_ state: State, oldState: State?)
}

struct AppState: State {

    var sceneState: SceneState

    static func appStateReducer(action: Action, state: State?) -> State {
        guard var existingState = state else {
            return AppState(sceneState: sceneReducer(action: action,
                                                     state: state?.sceneState))
        }

        existingState.sceneState.mutate(with: action)
        return existingState
    }

    static func sceneReducer(action: Action, state: SceneState?) -> SceneState {
        return TabBarSceneState(state: state?.of(of: TabBarSceneState.self),
                                action: action)
    }
}
