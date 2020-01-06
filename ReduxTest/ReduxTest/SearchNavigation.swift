//
//  SearchNavigation.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 06/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

class SearchNavigationControllerCoordinator: Coordinator {
    weak var currentViewController: UIViewController?
    var parent: Coordinator?
    var children: [Coordinator] = []
    
    func start(_ state: SceneState?) -> UIViewController? {
        guard let state = state?.findScene(of: SearchNavigationControllerSceneState.self) else { return nil }
        let currentCtrl = SearchNavigationController()
        currentViewController = currentCtrl
        currentCtrl.coordinator = self
        currentCtrl.viewControllers = state.children.compactMap {
            if let coord = $0.coordinatorForScene {
                coord.parent = self
                children.append(coord)
                let ctrl = coord.start(state)
                (ctrl as? Coordinated)?.coordinator = coord
                return ctrl
            }
            return nil
        }
        return currentCtrl
    }
}

struct SearchNavigationControllerSceneState: SceneState {
    var coordinatorForScene: Coordinator? {
        let coordinator = SearchNavigationControllerCoordinator()
        return coordinator
    }
    
    var children: [SceneState] = []
    
    var presentingScene: SceneState?
    
    var viewControllerForScene: UIViewController {
        let navigation = SearchNavigationController()
        navigation.viewControllers = children.compactMap {
            $0.viewControllerForScene
        }
        return navigation
    }
    
}

class SearchNavigationController: UINavigationController, Coordinated {
    weak var coordinator: Coordinator?
}
