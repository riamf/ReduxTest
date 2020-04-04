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

    private func resolveNavigation(_ new: MainState, _ old: MainState?) {
        guard let old = old else { return }

        if new.repositories.navigationStack.count > old.repositories.navigationStack.count {
            if let last = new.repositories.navigationStack.last,
                let ctrl = last.navigationItemControllerType.init(environment, last.uniqueId) as? UIViewController {
                (currentViewController as? TabBarController)?
                    .repositoriesNavigation.pushViewController(ctrl, animated: true)
            }
        } else if new.repositories.navigationStack.count < old.repositories.navigationStack.count {
            (currentViewController as? TabBarController)?.repositoriesNavigation.popViewController(animated: true)
        }
    }
}
