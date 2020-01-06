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
        guard let state = state?.findScene(of: ViewControllerSceneState.self) else { return nil }
        let ctrl = ViewController.instantiate() as! ViewController
        ctrl.scene = state
        ctrl.coordinator = self
        currentViewController = ctrl
        
        return ctrl
    }
    
    func back() {
        environment.useCaseFactory.backFromSearch()
    }
    
    func showFilters() {
        environment.useCaseFactory.showFilters()
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
            if newUsers.filters.phrase == filtersState.phrase {
                self.users = newUsers.users
            }
        default:
            break
        }
    }
    
    var users: [User] = []
    var filtersState = FiltersState()
}

class ViewModel: NSObject {
    var users: [User] = []
    var filtersState = FiltersState()
    
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
        cell.textLabel?.text = users[indexPath.row].name
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
            viewModel.filtersState.phrase = (scene as? ViewControllerSceneState)?.filtersState.phrase ?? viewModel.filtersState.phrase
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
        environment.useCaseFactory.fetchUsers(filters: viewModel.filtersState)
        navigationItem.searchController = searchViewController
        searchViewController.obscuresBackgroundDuringPresentation = true
        searchViewController.searchBar.placeholder = "Search"
        searchViewController.searchBar.delegate = self
        definesPresentationContext = true
        
        let backbutton = UIBarButtonItem(title: "BACK",
                                         style: .plain,
                                         target: self,
                                         action: #selector(backAction))
        navigationItem.leftBarButtonItem = backbutton
        
        let filter = UIBarButtonItem(title: "FILTER",
                                     style: .plain,
                                     target: self,
                                     action: #selector(showFilters))
        navigationItem.rightBarButtonItem = filter
    }
    
    @objc private func backAction() {
        (coordinator as? ViewControllerCoordinator)?.back()
    }
    
    @objc private func showFilters() {
        (coordinator as? ViewControllerCoordinator)?.showFilters()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        environment.useCaseFactory.showNewSearch(with: FiltersState(order: .asc,
                                                                    phrase: searchBar.text ?? ""))
    }
}

extension UIViewController {
    static func instantiate<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let id = String(describing: "\(self)")
        return storyboard.instantiateViewController(identifier: id) as! T
    }
}
