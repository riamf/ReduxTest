//
//  UseCaseFactory.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 30/12/2019.
//  Copyright © 2019 alpha. All rights reserved.
//

import Foundation

class UseCaseFactory {
    
    func takeOff() {
        environment.store.dispatch(TakeOffAction())
    }
    
    func fetchUsers(filters: FiltersState) {
        environment.store.dispatch(FetchUsersAction(filters: filters))
    }
    
    func showUsers() {
        environment.store.dispatch(ShowUsers())
    }
    
    func showNewSearch(with filters: FiltersState) {
        environment.store.dispatch(NewSearch(filters: filters))
    }
    
    func backFromSearch() {
        environment.store.dispatch(PopSearch())
    }
    
    func showFilters() {
        environment.store.dispatch(ShowFilters())
    }
    
    func applyFilters(selected: FiltersState) {
        environment.store.dispatch(ApplyFilters(state: selected))
    }
}
