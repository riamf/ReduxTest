//
//  TabBarController.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 02/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

struct TabBarScene: Scene {
    var children: [Scene] = []
    var presentingScene: Scene?
    var viewControllerForScene: UIViewController {
        return TabBarController(scene: self)
    }
    
    mutating func mutate(with action: Action) {}
}

class TabBarController: UITabBarController {
    var scene: TabBarScene? {
        didSet {
            
        }
    }
    
    convenience init(scene: TabBarScene?) {
        self.init(nibName: nil, bundle: nil)
        self.scene = scene
        setupViewControllers()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupViewControllers() {
        guard let scene = scene else { return }
        viewControllers = scene.children.map {
            $0.viewControllerForScene
        }
    }
}
