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
}
