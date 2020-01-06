//
//  State.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 30/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import UIKit

protocol State {
    var scene: SceneState? { get set }
}

protocol StateChangeObserver {
    func notify(_ state: State, oldState: State?)
}

struct AppState: State {
    
    var scene: SceneState?

    static func appStateReducer(action: Action, state: State?) -> State {
        return AppState(scene: sceneResolver(action: action, state: state))
    }
    
    static func sceneResolver(action: Action, state: State?) -> SceneState? {
        guard let state = state else {
            return TabBarScene(children: [
                SearchNavigationControllerSceneState(children: [
                    ViewControllerSceneState(children: [])
                ])
            ])
        }
        
        return TabBarScene(children: tabBarChildrenReducer(action: action,
                                                           children: state.scene?.children),
                           presentingScene: state.scene?.presentingScene)
    }
    
    static func tabBarChildrenReducer(action: Action, children: [SceneState]?) -> [SceneState] {
        guard var children = children else { return [] }
        
        for i in (0..<children.count) {
            var tmp = children[i]
            tmp.mutate(with: action)
            children[i] = tmp
        }
        
        return children
    }
}

struct ViewControllerState: State {
    var scene: SceneState?
    var children: [State] = []
    var users: [User] = []

    mutating func setUsers(_ users: [User]) {
        self.users = users
    }
}
