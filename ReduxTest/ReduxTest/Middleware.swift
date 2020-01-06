//
//  Middleware.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 30/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import Foundation

struct M {
    static let AppState: Middleware<State> = { dispatch, getState in
        return { next in
            return  { action in
                next(action)
            }
        }
    }
}

extension M {
    static let ViewController: Middleware<State> = { dispatch, getState in
        return { next in
            return { action in
                guard let fetchAction = action as? FetchUsersAction, let state = getState() else {
                    next(action)
                    return
                }
                GHClient().getUsers(filters: fetchAction.filters) { (result) in
                    switch result {
                    case .success(let items):
                        dispatch(NewUsers(users: items.items, filters: fetchAction.filters))
                    case .failure(_):
                        dispatch(ShowError())
                    }
                }
            }
        }
    }
}
