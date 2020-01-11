import UIKit

class SearchResultsCoordinator: Coordinator {
    var currentViewController: UIViewController?
    
    var children: [Coordinator] = []
    
    var parent: Coordinator?
    
    required init() {}
    
    func start(_ state: SceneState?) -> UIViewController? {
        guard let state = state?.of(of: SearchResultsState.self) else { return nil }
        
        let ctrl = SearchResultsViewController(items: state.items)
        ctrl.coordinator = self
        return ctrl
    }
}
