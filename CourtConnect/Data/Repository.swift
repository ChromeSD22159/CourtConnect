//
//  Repository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

class Repository {
    let userRepository: UserRepository
    
    @MainActor init(type: RepositoryType) {
        self.userRepository = UserRepository(type: type)
    }
} 


