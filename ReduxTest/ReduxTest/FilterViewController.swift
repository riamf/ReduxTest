//
//  FilterViewController.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 06/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

enum Order: String {
    case asc
    case desc
}

struct FilterViewControllerState: SceneState {
    
    var children: [SceneState] = []
    
    var presentingScene: SceneState?
    var order: Order = .asc
    
    var viewControllerForScene: UIViewController {
        return FilterViewController.instantiate()
    }
    
    var coordinatorForScene: Coordinator? {
        return FilterViewControllerCoordinator()
    }
}

class FilterViewControllerCoordinator: Coordinator {
    var currentViewController: UIViewController?
    
    var children: [Coordinator] = []
    var parent: Coordinator?
    
    func start(_ state: SceneState?) -> UIViewController? {
        return FilterViewController.instantiate()
    }
    
}

struct FiltersState: Equatable {
    var order: Order = .asc
    var phrase: String = ""
}

class FilterViewController: UIViewController, Coordinated {
    weak var coordinator: Coordinator?
    var viewModel = FiltersState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func sortOrder(sw: UISwitch) {
        viewModel.order = sw.isOn ? .asc : .desc
    }
    
    @IBAction private func applyFilters() {
        
    }
}
