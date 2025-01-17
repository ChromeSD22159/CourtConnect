//
//  Repository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import Foundation

class Repository {
    let userRepository: UserRepository
    let chatRepository: ChatRepository
    
    @MainActor init(type: RepositoryType) {
        self.userRepository = UserRepository(type: type)
        self.chatRepository = ChatRepository(type: type)
    }
} 


