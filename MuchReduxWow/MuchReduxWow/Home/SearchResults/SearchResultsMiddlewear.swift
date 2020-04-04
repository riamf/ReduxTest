extension M {
    static let SearchResults: Middleware<State> = { dispatch, getState in
        return { next in
            return { action in
                guard let searchAction = action as? SearchAction, let state = getState() else {
                    next(action)
                    return
                }
                GHClient().getRepositories(filters: searchAction.filter) { (result) in
                    switch result {
                    case .success(let items):
                        dispatch(NewDataAction(items: items,
                                               filter: searchAction.filter))
                    case .failure:
                        break
                    }
                }
            }
        }
    }
}
