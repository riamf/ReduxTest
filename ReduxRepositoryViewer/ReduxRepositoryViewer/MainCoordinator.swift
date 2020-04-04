import UIKit

protocol Coordinator {
    var currentViewController: UIViewController? { get }
}

class MainCoordinator: Coordinator {

    var currentViewController: UIViewController?
    var environment: AppEnvironment
    var window: UIWindow?
    private var tabBar: TabBarController? {
        return currentViewController as? TabBarController
    }

    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        environment = AppEnvironment()
        environment.store.onChange { [weak self] new, old in
            self?.resolve(state: new, old: old)
        }
    }

    func start() {
        window?.rootViewController = currentViewController
        window?.makeKeyAndVisible()
    }

    private func resolve(state: MainState, old: MainState?) {
        if currentViewController == nil {
            currentViewController = TabBarController(environment)
        } else {
            resolveNavigation(state, old)
        }
    }

    private func resolveNavigation(_ state: MainState, _ old: MainState?) {
        guard let old = old else { return }

        if let _ = state.repositories.repositoryDetails,
            old.repositories.repositoryDetails == nil {
            // push details
            tabBar?.repositoriesNavigation.pushViewController(RepositoryDetailsViewController(environment),
                                                                             animated: true)
        } else if state.repositories.repositoryDetails == nil && old.repositories.repositoryDetails != nil {
            // pop details
            tabBar?.repositoriesNavigation.popViewController(animated: true)
        }
    }
}
