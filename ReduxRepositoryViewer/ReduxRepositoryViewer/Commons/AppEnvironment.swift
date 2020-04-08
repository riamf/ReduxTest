import Foundation
import GHClient
import SimpleRedux

final class AppEnvironment {

    static let ghClient = GHClient()

    let store: ReduxStore<MainState>
    init() {
        let repositoriesList = RepositoriesListState(repositories: [], since: 0, uniqueId: 0)
        let navigation = RepositoriesNavigationState(navigationStack: [repositoriesList])
        store = ReduxStore(state: MainState(history: HistoryState(),
                                            repositories: navigation),
                           middleware: [RepositoriesMiddleware.ghClient, RepositoriesMiddleware.ghSearchClient])
    }

    func load(_ state: MainState) {
        store.dispatch(LoadState(state))
    }
}
