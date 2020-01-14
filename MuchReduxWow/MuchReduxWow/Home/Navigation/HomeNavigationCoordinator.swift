import UIKit

class HomeNavigationCoordinator: Coordinator {
    weak var currentViewController: UIViewController?
    weak var parent: Coordinator?
    var children: [Coordinator] = []
    
    required init() {
        environment.store.add(subscriber: self)
    }
    
    func start(_ state: SceneState?) -> UIViewController? {
        guard let state = state?.of(of: HomeNavigationState.self) else { return nil }
        let ctrl = HomeNavigationViewController()
        ctrl.coordinator = self
        currentViewController = ctrl
        addChildren(to: ctrl, state: state)
        return ctrl
    }
}

extension HomeNavigationCoordinator: StateChangeObserver {
    
    func notify(_ state: State, oldState: State?) {
        guard let newChildren = state.sceneState.of(of: HomeNavigationState.self)?.children,
            let oldChildren = oldState?.sceneState.of(of: HomeNavigationState.self)?.children else { return }
        
        let diff = newChildren.count - oldChildren.count
        if diff == 0 {
            // Presenting
            presenting(oldState: oldState?.sceneState.of(of: HomeNavigationState.self),
                       newState: state.sceneState.of(of: HomeNavigationState.self))
        } else if diff > 0, let last = newChildren.last {
            // Pushing
            let coord = last.coordinatorType.init()
            if let ctrl = coord.start(state.sceneState) {
                children.append(coord)
                coord.parent = self
                (currentViewController as? UINavigationController)?.pushViewController(ctrl, animated: true)
            }
        } else {
            // popping
            (currentViewController as? UINavigationController)?.popViewController(animated: true)
            children.removeLast()
        }
    }
    
    func presenting(oldState: HomeNavigationState?, newState: HomeNavigationState?) {
        guard let oldState = oldState, let newState = newState else { return }
        let presentNewOne = { [weak currentViewController] in
            let coordinator = newState.presentingScene?.coordinatorType.init()
            if let ctrl = coordinator?.start(newState.presentingScene) {
                (ctrl as? Coordinated)?.coordinator = coordinator
                currentViewController?.present(ctrl, animated: true, completion: nil)
            }
        }
        if let _ = oldState.presentingScene, newState.presentingScene == nil {
            currentViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        } else if oldState.presentingScene == nil, newState.presentingScene != nil {
            presentNewOne()
        }
    }
}
