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

struct SearchRepositories: Action {
    let page: Int
    let isNextPage: Bool
    let uniqueId: Int
    let phrase: String
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
