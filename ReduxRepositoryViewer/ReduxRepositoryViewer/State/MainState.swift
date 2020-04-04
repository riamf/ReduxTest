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


struct MainState: State {
    typealias ActionType = MainStateAction
    
    let profile: ProfileState
    let repositories: RepositoriesNavigationState
    
    func reduce(_ action: Action, _ state: MainState, _ hasChanged: inout Bool) -> MainState {
        return MainState(profile: state.profile.reduce(action, state.profile, &hasChanged),
                         repositories: state.repositories.reduce(action, state.repositories, &hasChanged))
    }
    
    static func reduce(_ action: Action, _ state: MainState, _ hasChanged: inout Bool) -> MainState {
        return state.reduce(action, state, &hasChanged)
    }
}

struct ProfileState: State {
    typealias ActionType = ProfileAction
    let title = "Profile"
    func reduce(_ action: Action, _ state: ProfileState, _ hasChanged: inout Bool) -> ProfileState {
        return state
    }
}

struct RepositoriesNavigationState: State {
    typealias ActionType = RepositoriesNavitationAction
    let repositoriesList: RepositoriesListState
    var repositoryDetails: RepositoryDetailsState?
    
    func reduce(_ action: Action, _ state: RepositoriesNavigationState, _ hasChanged: inout Bool) -> RepositoriesNavigationState {
        var details: RepositoryDetailsState? = state.repositoryDetails
        if let pushDetails = action as? ShowDetails {
            details = RepositoryDetailsState(repository: pushDetails.repository)
            hasChanged = true
        } else if action is PopDetails {
            details = nil
            hasChanged = true
        }
        if let tmp = details {
            details = tmp.reduce(action, tmp, &hasChanged)
        }
        
        return RepositoriesNavigationState(repositoriesList: state.repositoriesList.reduce(action, state.repositoriesList, &hasChanged),
                                           repositoryDetails: details)
    }
}

struct RepositoriesListState: State {
    typealias ActionType = RepositoriesListAction
    let repositories: [Repository]
    let since: Int
    let title = "Repositories"
    func reduce(_ action: Action, _ state: RepositoriesListState, _ hasChanged: inout Bool) -> RepositoriesListState {
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
    typealias ActionType = RepositoryDetailsStateAction
    let repository: Repository
    func reduce(_ action: Action, _ state: RepositoryDetailsState, _ hasChanged: inout Bool) -> RepositoryDetailsState {
        return state
    }
}

final class AppEnvironment {
    
    static let ghClient = GHClient()
 
    let store: ReduxStore<MainState>
    init() {
        store = ReduxStore(state: MainState(profile: ProfileState(),
                                            repositories: RepositoriesNavigationState(repositoriesList: RepositoriesListState(repositories: [], since: 0), repositoryDetails: nil)),
                           middleware: [M.ghClient])
    }
}

struct M {
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
