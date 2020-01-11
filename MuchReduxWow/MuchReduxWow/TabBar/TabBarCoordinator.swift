import UIKit

class TabBarControllerCoordinator: Coordinator {
    var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?
    
    required init() { }
    
    func start(_ state: SceneState?) -> UIViewController? {
        let ctrl = TabBarController()
        currentViewController = ctrl
        ctrl.coordinator = self
        return ctrl
    }
    
}
