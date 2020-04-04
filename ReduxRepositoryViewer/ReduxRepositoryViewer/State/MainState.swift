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
}

struct NewRepositories: RepositoriesListAction {
    let repositories: [Repository]
    let isNextPage: Bool
}

struct ShowDetails: Action {
    let repository: Repository
}

struct PopDetails: Action {}

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

struct ProfileState: State {
    let title = "Profile"
}

struct RepositoriesNavigationState: State {
    let repositoriesList: RepositoriesListState
    var repositoryDetails: RepositoryDetailsState?

    static func reduce(_ action: Action,
                       _ state: RepositoriesNavigationState,
                       _ hasChanged: inout Bool) -> RepositoriesNavigationState {
        var details: RepositoryDetailsState? = state.repositoryDetails
        if let pushDetails = action as? ShowDetails {
            details = RepositoryDetailsState(repository: pushDetails.repository)
            hasChanged = true
        } else if action is PopDetails {
            details = nil
            hasChanged = true
        }
        if let tmp = details {
            details = RepositoryDetailsState.reduce(action, tmp, &hasChanged)
        }

        return RepositoriesNavigationState(repositoriesList: RepositoriesListState.reduce(action,
                                                                                          state.repositoriesList,
                                                                                          &hasChanged),
                                           repositoryDetails: details)
    }
}

struct RepositoriesListState: State {
    let repositories: [Repository]
    let since: Int
    let title = "Repositories"
    static func reduce(_ action: Action,
                       _ state: RepositoriesListState,
                       _ hasChanged: inout Bool) -> RepositoriesListState {
        switch action {
        case let action as NewRepositories:
            hasChanged = true
            let repositories = action.isNextPage ? state.repositories + action.repositories : action.repositories
            return RepositoriesListState(repositories: repositories, since: action.repositories.last?.id ?? 0)
        default:
            break
        }
        return state
    }
}

struct RepositoryDetailsState: State {
    let repository: Repository
}

final class AppEnvironment {

    static let ghClient = GHClient()

    let store: ReduxStore<MainState>
    init() {
        let repositoriesList = RepositoriesListState(repositories: [], since: 0)
        let navigation = RepositoriesNavigationState(repositoriesList: repositoriesList,
                                                     repositoryDetails: nil)
        store = ReduxStore(state: MainState(history: HistoryState(),
                                            repositories: navigation),
                           middleware: [RepositoriesMiddleware.ghClient])
    }

    func load(_ state: MainState) {
        store.dispatch(LoadState(state))
    }
}

struct RepositoriesMiddleware {
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
                        dispatch(NewRepositories(repositories: repositories, isNextPage: downloadAction.isNextPage))
                    case .failure(let error):
                        break
                    }
                }
            }
        }
    }
}
