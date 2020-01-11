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
            window?.rootViewController = start(state.sceneState)
            currentViewController = window?.rootViewController
            window?.makeKeyAndVisible()
        }
    }
}
