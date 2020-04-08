import Foundation
import SimpleRedux

struct RepositoriesNavigationState: State {

    static private var uniqueID = (1...).makeIterator()

    let navigationStack: [NavigationStackItem]

    static func reduce(_ action: Action,
                       _ state: RepositoriesNavigationState,
                       _ hasChanged: inout Bool) -> RepositoriesNavigationState {

        var navigationStack = state.navigationStack.map {
            type(of: $0).reduce(action, $0, &hasChanged)
        }
        switch action {
        case let action as ShowDetails:
            let details = RepositoryDetailsState(repository: action.repository, uniqueId: uniqueID.next()!)
            hasChanged = true
            navigationStack.append(details)
        case _ as PopDetails:
            hasChanged = true
            navigationStack.removeLast()
        case let action as NewSearch:
            let searchResults = SearchResultsState(repositories: [],
                                                   page: 0,
                                                   phrase: action.phrase,
                                                   title: "Search for \(action.phrase)",
                                                   uniqueId: uniqueID.next()!)
            navigationStack.append(searchResults)
            hasChanged = true
        case _ as PopResults:
            hasChanged = true
            navigationStack.removeLast()
        default:
            break
        }

        return RepositoriesNavigationState(navigationStack: navigationStack)
    }

    func item<T>(for uniqueId: Int) -> T? {
        return navigationStack.first(where: { $0.uniqueId == uniqueId }) as? T
    }
}

protocol NavigationItemController {
    var environment: AppEnvironment! { get }
    var uniqueId: Int! { get }
    init(_ environment: AppEnvironment, _ uniqueId: Int)
}

protocol NavigationStackItem {
    var navigationItemControllerType: NavigationItemController.Type { get }
    var uniqueId: Int { get }

    static func reduce(_ action: Action,
                       _ state: NavigationStackItem,
                       _ hasChanged: inout Bool) -> NavigationStackItem
}
