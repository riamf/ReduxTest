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
    
    func fetchUsers() {
        environment.store.dispatch(FetchUsersAction())
    }
    
    func showUsers() {
        environment.store.dispatch(ShowUsers())
    }
}
