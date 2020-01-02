//
//  Coordinator.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 30/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var currentViewController: UIViewController? { get }
    var children: [Coordinator] { get }
    var parent: Coordinator? { get set }
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
            start(state)
        }
    }
    
    func showError() {
        let error = ErrorViewController()
        currentViewController?.present(error, animated: true, completion: nil)
    }
    
    func hideError() {
        currentViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func start(_ state: State) {
        if window?.isKeyWindow == false {
            let ctrl = TabBarController(scene: state.scene as? TabBarScene)
            window?.rootViewController = ctrl
            currentViewController = window?.rootViewController
            window?.makeKeyAndVisible()
        }
    }
}
