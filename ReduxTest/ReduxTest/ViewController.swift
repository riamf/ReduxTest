//
//  ViewController.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 19/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import UIKit

class ViewControllerCoordinator: Coordinator {
    var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?
    
    func start(_ state: SceneState?) -> UIViewController? {
        let ctrl = ViewController.instantiate() as! ViewController
        ctrl.coordinator = self
        currentViewController = ctrl
        
        return ctrl
    }
}

struct ViewControllerSceneState: SceneState {
    var coordinatorForScene: Coordinator? {
        let coordinator = ViewControllerCoordinator()
        return coordinator
    }
    
    var children: [SceneState]
    var presentingScene: SceneState?
    var viewControllerForScene: UIViewController {
        let ctrl = ViewController.instantiate()
        (ctrl as? ViewController)?.scene = self
        return ctrl
    }
    
    mutating func mutate(with action: Action) {
        switch action {
        case let newUsers as NewUsers:
            self.users = newUsers.users
        default:
            break
        }
    }
    
    var users: [User] = []
}

class ViewModel: NSObject {
    var users: [User] = []
    
    func update(_ users: [User]) {
        self.users = users
    }
}

extension ViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].login
        return cell
    }
}

class ViewController: UIViewController, StateChangeObserver, Coordinated {
    
    weak var coordinator: Coordinator?
    var viewModel = ViewModel()
    let searchViewController = UISearchController(searchResultsController: nil)
    var scene: SceneState? {
        didSet {
            viewModel.users = (scene as? ViewControllerSceneState)?.users ?? viewModel.users
        }
    }
    @IBOutlet private weak var table: UITableView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        environment.store.subscribers.addPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
    func notify(_ state: State, oldState: State?) {
        scene = state.scene?.findScene(of: ViewControllerSceneState.self)
        table.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = viewModel
        environment.useCaseFactory.fetchUsers()
        navigationItem.searchController = searchViewController
        searchViewController.obscuresBackgroundDuringPresentation = true
        searchViewController.searchResultsUpdater = self
        searchViewController.searchBar.placeholder = "Search"
        definesPresentationContext = true
    }
}

extension UIViewController {
    static func instantiate<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let id = String(describing: "\(self)")
        return storyboard.instantiateViewController(identifier: id) as! T
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
