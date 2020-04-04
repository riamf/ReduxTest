//
//  AppDelegate.swift
//  MuchReduxWow
//
//  Created by Pawel Kowalczuk on 11/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

let environment = AppEnvironment()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        environment.coordinator = MainCoordinator(window: window)
        environment.useCaseFactory.takeOff()

        return true
    }
}
