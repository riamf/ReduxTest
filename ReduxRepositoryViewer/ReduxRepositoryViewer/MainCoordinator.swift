import UIKit

protocol Coordinator {
    var currentViewController: UIViewController? { get }
}

class MainCoordinator: Coordinator {

    var currentViewController: UIViewController?
    var environment: AppEnvironment
    var window: UIWindow?
    private var repositoriesNavigation: RepositoriesNavigtion? {
        return (currentViewController as? TabBarController)?.repositoriesNavigation
    }
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
            let start = old.repositories.navigationStack.count
            let end = new.repositories.navigationStack.count
            for idx in (start..<end) {
                let next = new.repositories.navigationStack[idx]
                if let ctrl = next.navigationItemControllerType.init(environment, next.uniqueId) as? UIViewController {
                    repositoriesNavigation?.pushViewController(ctrl, animated: idx == (end - 1))
                }
            }
        } else if new.repositories.navigationStack.count < old.repositories.navigationStack.count {
            let diff = old.repositories.navigationStack.count - new.repositories.navigationStack.count
            (0..<diff).forEach {
                repositoriesNavigation?.popViewController(animated: $0 == (diff - 1))
            }
        }
    }
}
