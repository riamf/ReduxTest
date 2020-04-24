import UIKit

protocol Coordinated: class {
    var coordinator: Coordinator? { get set }
}

protocol Coordinator: class {
    var currentViewController: UIViewController? { get }
    var children: [Coordinator] { get set }
    var parent: Coordinator? { get set }
    
    init()
    @discardableResult func start(_ state: SceneState?) -> UIViewController?

    func addChildren(to navigation: UINavigationController, state: SceneState)
}

extension Coordinator {
    func addChildren(to navigation: UINavigationController, state: SceneState) {
        let tmp = state.children.map { item -> (Coordinator, UIViewController?) in
            let coord = item.coordinatorType.init()
            coord.parent = self
            return (coord, coord.start(state))
        }
        
        children = tmp.compactMap { $0.0 }
        navigation.setViewControllers(tmp.compactMap { $0.1 }, animated: false)
    }
}

class MainCoordinator: Coordinator {
    
    var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?
    
    private(set) weak var window: UIWindow?
    
    required init() {}
    
    convenience init(window: UIWindow?) {
        self.init()
        self.window = window
        environment.store.add(subscriber: self)
    }
    
    @discardableResult
    func start(_ state: SceneState?) -> UIViewController? {
        guard let coordinator = state?.coordinatorType.init() else { return nil }
        children.append(coordinator)
        coordinator.parent = self
        return coordinator.start(state)
    }
}

extension MainCoordinator: StateChangeObserver {
    func notify(_ state: State, oldState: State?) {
        if currentViewController == nil {
            let ctrl = start(state.sceneState)
            (ctrl as? Coordinated)?.coordinator = self
            window?.rootViewController = ctrl
            currentViewController = window?.rootViewController
            window?.makeKeyAndVisible()
        }
    }
}
