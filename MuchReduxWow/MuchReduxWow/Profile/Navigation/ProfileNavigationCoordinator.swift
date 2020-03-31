import UIKit

class ProfileNavigationCoordinator: Coordinator {
    
    weak var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?
    
    required init() {}
    
    func start(_ state: SceneState?) -> UIViewController? {
        guard let state = state?.of(of: ProfileNavigationState.self) else { return nil }
        let ctrl = ProfileNavigationController()
        ctrl.coordinator = self
        currentViewController = ctrl
        addChildren(to: ctrl, state: state)
        
        return ctrl
    }
}
