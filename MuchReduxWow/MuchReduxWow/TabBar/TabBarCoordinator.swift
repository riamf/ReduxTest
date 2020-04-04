import UIKit

class TabBarControllerCoordinator: Coordinator {
    var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?

    required init() { }

    func start(_ state: SceneState?) -> UIViewController? {
        guard let state = state?.of(of: TabBarSceneState.self) else { return nil }
        let ctrl = TabBarController()
        currentViewController = ctrl
        ctrl.coordinator = self

        let tmp = state.children.compactMap { itm -> (Coordinator, UIViewController?) in
            let coord = itm.coordinatorType.init()
            coord.parent = self
            return (coord, coord.start(state))
        }

        children = tmp.map { $0.0 }
        ctrl.setViewControllers(tmp.compactMap { $0.1 }, animated: false)

        return ctrl
    }

}
