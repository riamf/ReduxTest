import Foundation
import GHClient
import SimpleRedux

final class AppEnvironment {

    static let ghClient = GHClient()

    let store: ReduxStore<MainState>
    let useCases: UseCases
    init() {
        let repositoriesList = RepositoriesListState(repositories: [], since: 0, uniqueId: 0)
        let navigation = RepositoriesNavigationState(navigationStack: [repositoriesList])
        store = ReduxStore(state: MainState(history: HistoryState(),
                                            repositories: navigation),
                           middleware: [RepositoriesMiddleware.ghClient, RepositoriesMiddleware.ghSearchClient])
        useCases = UseCases(store: store)
    }

    func load(_ state: MainState) {
        store.dispatch(LoadState(state))
    }
}

struct UseCases {
    private weak var store: ReduxStore<MainState>?
    init(store: ReduxStore<MainState>) {
        self.store = store
    }

    func searchRepositories(page: Int, isNextPage: Bool, uniqueId: Int, phrase: String) {
        store?.dispatch(SearchRepositories(page: page,
                                           isNextPage: isNextPage,
                                           uniqueId: uniqueId,
                                           phrase: phrase))
    }

    func popResults() {
        store?.dispatch(PopResults())
    }

    func showDetails(for repository: Repository) {
        store?.dispatch(ShowDetails(repository: repository))
    }

    func showNewSearch(for phrase: String) {
        store?.dispatch(NewSearch(phrase: phrase))
    }

    func popDetails() {
        store?.dispatch(PopDetails())
    }

    func downloadRepositories(since: Int, isNextPage: Bool, uniqueId: Int) {
        store?.dispatch(DownloadRepositories(since: since,
                                             isNextPage: isNextPage,
                                             uniqueId: uniqueId))
    }
}
