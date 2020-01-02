//
//  ViewController.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 19/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import UIKit

struct ViewControllerScene: Scene {
    var children: [Scene]
    var presentingScene: Scene?
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

class ViewController: UIViewController, StateChangeObserver {
    
    var viewModel = ViewModel()
    var scene: Scene? {
        didSet {
            viewModel.users = (scene as? ViewControllerScene)?.users ?? viewModel.users
        }
    }
    @IBOutlet private weak var table: UITableView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        environment.store.subscribers.addPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
    func notify(_ state: State, oldState: State?) {
        guard let strongScene = scene as? ViewControllerScene else { return }
        scene = state.scene?.findScene(of: ViewControllerScene.self)
        table.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = viewModel
        environment.useCaseFactory.fetchUsers()
    }
}


extension UIViewController {
    static func instantiate() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let id = String(describing: "\(self)")
        return storyboard.instantiateViewController(identifier: id)
    }
}

class ErrorViewController: UIViewController {
    override func loadView() {
        view = UIView(frame: .zero)
        let closeButton = UIButton(frame: .zero)
        closeButton.setTitle("CLOSE", for: .normal)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        closeButton.addTarget(self, action: #selector(closeError), for: .touchUpInside)
    }
    
    @objc private func closeError() {
        environment.store.dispatch(HideError())
    }
}
