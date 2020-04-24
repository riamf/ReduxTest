import Foundation
import GHClient
import SimpleRedux

struct RepositoriesListState: State, NavigationStackItem {
    let repositories: [Repository]
    let since: Int
    let phrase: String = ""
    let title = "Repositories"
    let uniqueId: Int
    var navigationItemControllerType: NavigationItemController.Type {
        return RepositoriesViewController.self
    }

    static func reduce(_ action: Action,
                       _ state: RepositoriesListState,
                       _ hasChanged: inout Bool) -> RepositoriesListState {
        switch action {
        case let action as NewRepositories where action.uniqueId == state.uniqueId:
            hasChanged = true
            let repositories = action.isNextPage ? state.repositories + action.repositories : action.repositories
            return RepositoriesListState(repositories: repositories,
                                         since: action.repositories.last?.id ?? 0,
                                         uniqueId: state.uniqueId)
        default:
            break
        }
        return state
    }

    static func reduce(_ action: Action,
                       _ state: NavigationStackItem,
                       _ hasChanged: inout Bool) -> NavigationStackItem {
        guard let selfState = state as? Self else { return state }
        return RepositoriesListState.reduce(action, selfState, &hasChanged)
    }
}
