import UIKit

class FiltersCoordinator: Coordinator {
    
    var currentViewController: UIViewController?
    var children: [Coordinator] = []
    var parent: Coordinator?
    
    required init() { }
    
    func start(_ state: SceneState?) -> UIViewController? {
        guard let state = state as? FiltersSceneState else { return nil }
        let ctrl = FiltersViewController(selected: state.preselected)
        ctrl.coordinator = self
        return ctrl
    }
}
