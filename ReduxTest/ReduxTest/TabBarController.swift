//
//  TabBarController.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 02/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

struct TabBarScene: SceneState {
    var coordinatorForScene: Coordinator? { return nil }
    
    var children: [SceneState] = []
    var presentingScene: SceneState?
    var viewControllerForScene: UIViewController {
        return TabBarController(scene: self)
    }
    
    mutating func mutate(with action: Action) {}
}

class TabBarController: UITabBarController, Coordinated {
    var scene: SceneState?
    weak var coordinator: Coordinator?
    
    convenience init(scene: SceneState?) {
        self.init(nibName: nil, bundle: nil)
        self.scene = scene
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
