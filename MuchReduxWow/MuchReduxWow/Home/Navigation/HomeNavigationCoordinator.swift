import UIKit

class HomeNavigationCoordinator: Coordinator {
    weak var currentViewController: UIViewController?
    weak var parent: Coordinator?
    var children: [Coordinator] = []
    
    required init() { }
    
    func start(_ state: SceneState?) -> UIViewController? {
        guard let state = state?.of(of: HomeNavigationState.self) else { return nil }
        let ctrl = HomeNavigationViewController()
        ctrl.coordinator = self
        currentViewController = ctrl
        addChildren(to: ctrl, state: state)
        return ctrl
    }
}
