import Foundation

extension M {
    static let Filters: Middleware<State> = { dispatch, getState in
        return { next in
            return { action in
                guard let searchAction = action as? FetchLanguages, let state = getState() else {
                    next(action)
                    return
                }
                GHClient().getLanguages { result in
                    switch result {
                    case .success(let languages):
                        dispatch(NewLanguages(languages: languages))
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
}
