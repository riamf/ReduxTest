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
                guard action is FetchUsersAction, let state = getState() else {
                    next(action)
                    return
                }
                GHClient().getUsers { (result) in
                    switch result {
                    case .success(let users):
                        dispatch(NewUsers(users: users))
                    case .failure(_):
                        dispatch(ShowError())
                    }
                }
            }
        }
    }
}
