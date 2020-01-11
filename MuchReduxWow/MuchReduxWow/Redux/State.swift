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
        return AppState(sceneState: sceneReducer(action: action,
                                                 state: state?.sceneState))
    }
    
    static func sceneReducer(action: Action, state: SceneState?) -> SceneState {
        return TabBarSceneState(state: state?.of(of: TabBarSceneState.self),
                                action: action)
    }
}
