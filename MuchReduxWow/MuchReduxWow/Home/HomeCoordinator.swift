import UIKit

class HomeCoordinator: Coordinator {
    weak var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?

    required init() { }

    func start(_ state: SceneState?) -> UIViewController? {
        let ctrl = HomeViewController()
        currentViewController = ctrl
        return ctrl
    }
}
