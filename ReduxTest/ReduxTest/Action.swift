//
//  Action.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 30/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import Foundation

protocol Action {}
struct ShowUsers: Action {}
struct FetchUsersAction: Action {
    let filters: FiltersState
}
struct TakeOffAction: Action {}
struct HideError: Action {}
struct ShowError: Action {}
struct NewUsers: Action, Equatable {
    let users: [User]
    let filters: FiltersState
}
struct NewSearch: Action {
    let filters: FiltersState
}

struct PopSearch: Action {}
struct ShowFilters: Action {
    
}
struct ApplyFilters: Action {
    let state: FiltersState
}
