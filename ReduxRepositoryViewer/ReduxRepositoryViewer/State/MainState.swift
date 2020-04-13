import Foundation
import SimpleRedux
import GHClient

protocol MainStateAction: Action {}
protocol ProfileAction: Action {}
protocol RepositoriesNavitationAction: Action {}
protocol RepositoriesListAction: Action {}
protocol RepositoryDetailsStateAction: Action {}

struct DownloadRepositories: Action {
    let since: Int
    let isNextPage: Bool
    let uniqueId: Int
}

struct ShowSearchResults: Action {
    let repositories: [Repository]
    let phrase: String
    let uniqueId: Int
    let page: Int
    var isNextPage: Bool {
        return page > 0
    }
}

struct NewRepositories: RepositoriesListAction {
    let repositories: [Repository]
    let isNextPage: Bool
    let uniqueId: Int
}

struct ShowDetails: Action {
    let repository: Repository
}

struct NewSearch: Action {
    var phrase: String
    let page: Int
    let isNextPage: Bool
    let uniqueId: Int
}

struct PopDetails: Action {}
struct PopResults: Action {}

struct MainState: State, Reducable {

    let history: HistoryState
    let repositories: RepositoriesNavigationState

    static func reduce(_ action: Action, _ state: MainState, _ hasChanged: inout Bool) -> MainState {
        return MainState(history: HistoryState.reduce(action, state.history, &hasChanged),
                         repositories: RepositoriesNavigationState.reduce(action,
                                                                          state.repositories,
                                                                          &hasChanged))
    }
}

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
        case let action as ShowSearchResults:
            if !action.isNextPage {
                let newRepositoriesList = RepositoriesListState(repositories: action.repositories,
                                                                since: action.page,
                                                                phrase: action.phrase,
                                                                uniqueId: uniqueID.next()!)
                hasChanged = true
                navigationStack.append(newRepositoriesList)
            }
        case _ as PopResults:
            hasChanged = true
            navigationStack.removeLast()
        default:
            break
        }

        return RepositoriesNavigationState(navigationStack: navigationStack)
    }

    func details(for uniqueId: Int) -> RepositoryDetailsState? {
        return navigationStack.first(where: { $0.uniqueId == uniqueId }) as? RepositoryDetailsState
    }

    func list(for uniqueId: Int) -> RepositoriesListState? {
        return navigationStack.first(where: { $0.uniqueId == uniqueId }) as? RepositoriesListState
    }
}

protocol NavigationItemController {
    init(_ environment: AppEnvironment, _ uniqueId: Int)
}

protocol NavigationStackItem {
    var navigationItemControllerType: NavigationItemController.Type { get }
    var uniqueId: Int { get }

    static func reduce(_ action: Action,
                       _ state: NavigationStackItem,
                       _ hasChanged: inout Bool) -> NavigationStackItem
}

struct RepositoriesListState: State, NavigationStackItem {
    let repositories: [Repository]
    let since: Int
    let phrase: String?
    let title = "Repositories"
    let uniqueId: Int
    var navigationItemControllerType: NavigationItemController.Type {
        return RepositoriesViewController.self
    }

    static func reduce(_ action: Action,
                       _ state: RepositoriesListState,
                       _ hasChanged: inout Bool) -> RepositoriesListState {
        switch action {
        case let action as NewRepositories:
            if action.uniqueId == state.uniqueId {
                hasChanged = true
                let repositories = action.isNextPage ? state.repositories + action.repositories : action.repositories
                return RepositoriesListState(repositories: repositories,
                                             since: action.repositories.last?.id ?? 0,
                                             phrase: state.phrase,
                                             uniqueId: state.uniqueId)
            }
        case let action as ShowSearchResults:
            if action.isNextPage, action.uniqueId == state.uniqueId {
                hasChanged = true
                let repositories = state.repositories + action.repositories
                return RepositoriesListState(repositories: repositories,
                                             since: action.page,
                                             phrase: state.phrase,
                                             uniqueId: state.uniqueId)
            }
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

final class AppEnvironment {

    static let ghClient = GHClient()

    let store: ReduxStore<MainState>
    init() {
        let repositoriesList = RepositoriesListState(repositories: [], since: 0, phrase: nil, uniqueId: 0)
        let navigation = RepositoriesNavigationState(navigationStack: [repositoriesList])
        store = ReduxStore(state: MainState(history: HistoryState(),
                                            repositories: navigation),
                           middleware: [RepositoriesMiddleware.ghClient, RepositoriesMiddleware.ghSearchClient])
    }

    func load(_ state: MainState) {
        store.dispatch(LoadState(state))
    }
}

struct RepositoriesMiddleware {
    static let ghSearchClient: Middleware<MainState> = { dispatch, getState in
        return { next in
            return { action in
                guard let searchAction = action as? NewSearch else {
                    next(action)
                    return
                }

                AppEnvironment.ghClient.searchRepositories(searchAction.phrase, searchAction.page) { result in
                    switch result {
                    case .success(let repositories):
                        dispatch(ShowSearchResults(repositories: repositories,
                                                   phrase: searchAction.phrase,
                                                   uniqueId: searchAction.uniqueId,
                                                   page: searchAction.page))
                    case .failure(let error):
                        break
                    }
                }
            }

        }
    }
    static let ghClient: Middleware<MainState> = { dispatch, getState in
        return { next in
            return { action in
                guard let downloadAction = action as? DownloadRepositories else {
                    next(action)
                    return
                }

                AppEnvironment.ghClient.getRepositories(downloadAction.since) { result in
                    switch result {
                    case .success(let repositories):
                        dispatch(NewRepositories(repositories: repositories,
                                                 isNextPage: downloadAction.isNextPage,
                                                 uniqueId: downloadAction.uniqueId))
                    case .failure(let error):
                        break
                    }
                }
            }
        }
    }
}
