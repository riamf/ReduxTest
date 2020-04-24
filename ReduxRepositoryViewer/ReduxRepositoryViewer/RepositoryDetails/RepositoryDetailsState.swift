import Foundation
import SimpleRedux
import GHClient

struct RepositoryDetailsState: State, NavigationStackItem {
    let repository: Repository
    let uniqueId: Int

    var navigationItemControllerType: NavigationItemController.Type {
        return RepositoryDetailsViewController.self
    }
    static func reduce(_ action: Action,
                       _ state: NavigationStackItem,
                       _ hasChanged: inout Bool) -> NavigationStackItem {
        guard let selfState = state as? Self else { return state }
        return RepositoriesListState.reduce(action, selfState, &hasChanged)
    }
}
