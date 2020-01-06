//
//  Scene.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 06/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

protocol SceneState {
    var children: [SceneState] { get set }
    var presentingScene: SceneState? { get set }
    var viewControllerForScene: UIViewController { get }
    var coordinatorForScene: Coordinator? { get }
    mutating func mutate(with action: Action)
}

extension SceneState {
    func findScene<T>(of kind: T.Type) -> T? {
        guard type(of: self) == kind else {
            return children.reversed().compactMap({ $0.findScene(of: kind) }).first
        }
        return self as? T
    }
}

extension SceneState {
    mutating func mutate(with action: Action) {
        for i in (0..<children.count) {
            var tmp = children[i]
            tmp.mutate(with: action)
            children[i] = tmp
        }
    }
}
