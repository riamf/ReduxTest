import Foundation
import SimpleRedux

struct RepositoriesMiddleware {
    static let ghSearchClient: Middleware<MainState> = { dispatch, getState in
        return { next in
            return { action in
                guard let searchAction = action as? SearchRepositories else {
                    next(action)
                    return
                }

                AppEnvironment.ghClient.searchRepositories(searchAction.phrase, searchAction.page) { result in
                    switch result {
                    case .success(let repositories):
                        dispatch(NewRepositories(repositories: repositories,
                                                 isNextPage: searchAction.isNextPage,
                                                 uniqueId: searchAction.uniqueId))
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

