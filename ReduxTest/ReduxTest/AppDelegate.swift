//
//  AppDelegate.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 19/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import UIKit

class AppEnvironment {
    let store = ReduxStore(state: nil,
                           reducer: AppState.appStateReducer,
                           middleware: [M.AppState, M.ViewController])
    let useCaseFactory = UseCaseFactory()
    var coordinator: Coordinator!
}

var environment: AppEnvironment!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        environment = AppEnvironment()
        environment.coordinator = MainCoordinator(window: window)
        environment.useCaseFactory.takeOff()
        
        return true
    }
}
