//
//  SearchNavigation.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 06/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

class SearchNavigationControllerCoordinator: Coordinator, StateChangeObserver {
    weak var currentViewController: UIViewController?
    var parent: Coordinator?
    var children: [Coordinator] = []
    
    init() {
        environment.store.subscribers.addPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
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
    
    
    func notify(_ state: State, oldState: State?) {
        guard let myState = state.scene?.findScene(of: SearchNavigationControllerSceneState.self),
            let myOldState = oldState?.scene?.findScene(of: SearchNavigationControllerSceneState.self) else { return }
        
        // NOTE: problematic
        if myState.children.count > myOldState.children.count {
            var start = myOldState.children.count
            while start < myState.children.count {
                if let coord = myState.children[start].coordinatorForScene,
                     let ctrl = coord.start(myState) {
                    coord.parent = self
                    children.append(coord)
                    (ctrl as? Coordinated)?.coordinator = coord
                    (currentViewController as? UINavigationController)?.pushViewController(ctrl, animated: start == (myState.children.count - 1))
                }
                start += 1
            }
        } else if myState.children.count < myOldState.children.count {
            var start = myOldState.children.count
            while start > myState.children.count {
                _ = children.popLast()
                (currentViewController as? UINavigationController)?.popViewController(animated: myState.children.count == (start - 1))
                start -= 1
            }
        } else {
            
            if myState.presentingScene == nil && myOldState.presentingScene != nil {
                currentViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
            } else if let presenting = myState.presentingScene, myOldState.presentingScene == nil,
                let coord = presenting.coordinatorForScene,
                let ctrl = coord.start(myState) {
                (ctrl as? Coordinated)?.coordinator = coord
                children.append(coord)
                currentViewController?.present(ctrl, animated: true, completion: nil)
            }
        }
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
    
    mutating func mutate(with action: Action) {
        switch action {
        case let action as NewSearch:
            children.append(ViewControllerSceneState(children: [],
                                                     presentingScene: nil,
                                                     users: [],
                                                     filtersState: action.filters))
        case _ as PopSearch:
            _ = children.popLast()
        case _ as ShowFilters:
            presentingScene =  FilterViewControllerState()
        default:
            for i in (0..<children.count) {
                var tmp = children[i]
                tmp.mutate(with: action)
                children[i] = tmp
            }
        }
    }
}

class SearchNavigationController: UINavigationController, Coordinated {
    weak var coordinator: Coordinator?
}
