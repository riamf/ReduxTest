//
//  Coordinator.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 30/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import UIKit

protocol Coordinated: class {
    var coordinator: Coordinator? { get set }
}

protocol Coordinator: class {
    var currentViewController: UIViewController? { get }
    var children: [Coordinator] { get set }
    var parent: Coordinator? { get set }
    
    @discardableResult func start(_ state: SceneState?) -> UIViewController?
}

extension Coordinator {
    @discardableResult func start(_ state: SceneState?) -> UIViewController? { return nil }
}

class MainCoordinator: Coordinator, StateChangeObserver {
    weak var window: UIWindow?
    private(set) var currentViewController: UIViewController?
    weak var parent: Coordinator?
    
    var children: [Coordinator] = []
    
    init(window: UIWindow?) {
        self.window = window
        environment.store.subscribers.addPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
    func notify(_ state: State, oldState: State?) {
        if window?.rootViewController == nil && window?.isKeyWindow == false {
            // start required
            start(state.scene?.findScene(of: TabBarScene.self))
        }
    }
    
    func showError() {
        let error = ErrorViewController()
        currentViewController?.present(error, animated: true, completion: nil)
    }
    
    func hideError() {
        currentViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func start(_ state: SceneState?) {
        guard let state = state else { return }
        if window?.isKeyWindow == false {
            let ctrl = TabBarController(scene: state)
            ctrl.viewControllers = state.children.compactMap {
                if let coord = $0.coordinatorForScene {
                    coord.parent = self
                    children.append(coord)
                    let ctrl = coord.start(state)
                    return ctrl
                }
                return nil
            }
            window?.rootViewController = ctrl
            currentViewController = window?.rootViewController
            window?.makeKeyAndVisible()
        }
    }
}
