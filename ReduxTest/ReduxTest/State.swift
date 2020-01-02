//
//  State.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 30/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import UIKit

protocol State {
    var scene: Scene? { get set }
}

extension Scene {
    func findScene<T>(of kind: T.Type) -> T? {
        guard type(of: self) == kind else {
            return children.compactMap({ $0.findScene(of: kind) }).first
        }
        return self as? T
    }
}

protocol StateChangeObserver {
    func notify(_ state: State, oldState: State?)
}

protocol Scene {
    var children: [Scene] { get set }
    var presentingScene: Scene? { get set }
    var viewControllerForScene: UIViewController { get }
    mutating func mutate(with action: Action)
}

struct AppState: State {
    
    var scene: Scene?

    static func appStateReducer(action: Action, state: State?) -> State {
        return AppState(scene: sceneResolver(action: action, state: state))
    }
    
    static func sceneResolver(action: Action, state: State?) -> Scene? {
        guard let state = state else {
            return TabBarScene(children: [ViewControllerScene(children: [])])
        }
        
        return TabBarScene(children: tabBarChildrenReducer(action: action,
                                                           children: state.scene?.children),
                           presentingScene: state.scene?.presentingScene)
    }
    
    static func tabBarChildrenReducer(action: Action, children: [Scene]?) -> [Scene] {
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
    var scene: Scene?
    var children: [State] = []
    var users: [User] = []

    mutating func setUsers(_ users: [User]) {
        self.users = users
    }
}
