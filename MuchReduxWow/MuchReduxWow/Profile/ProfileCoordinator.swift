import UIKit

class ProfileCoordinator: Coordinator {
    weak var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?

    required init() {}

    func start(_ state: SceneState?) -> UIViewController? {
        let ctrl = ProfileViewController()
        currentViewController = ctrl
        ctrl.coordinator = self
        return ctrl
    }
}
