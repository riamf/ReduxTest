import Foundation
import GHClient
import SimpleRedux

struct SearchResultsState: State, NavigationStackItem {

    let repositories: [Repository]
    let page: Int
    let phrase: String
    let title: String
    let uniqueId: Int
    var navigationItemControllerType: NavigationItemController.Type {
        return SearchResultsViewController.self
    }

    static func reduce(_ action: Action,
                       _ state: SearchResultsState,
                       _ hasChanged: inout Bool) -> SearchResultsState {
        switch action {
        case let action as NewRepositories where action.uniqueId == state.uniqueId:
            let repositories = action.isNextPage ? state.repositories + action.repositories : action.repositories
            hasChanged = true
            return SearchResultsState(repositories: repositories,
                                      page: state.page + 1,
                                      phrase: state.phrase,
                                      title: state.title,
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
        return SearchResultsState.reduce(action, selfState, &hasChanged)
    }
}
