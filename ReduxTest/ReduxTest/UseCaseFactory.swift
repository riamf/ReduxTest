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
    
    func fetchUsers(phrase: String) {
        environment.store.dispatch(FetchUsersAction(phrase: phrase))
    }
    
    func showUsers() {
        environment.store.dispatch(ShowUsers())
    }
    
    func showNewSearch(with phrase: String) {
        environment.store.dispatch(NewSearch(phrase: phrase))
    }
    
    func backFromSearch() {
        environment.store.dispatch(PopSearch())
    }
}
