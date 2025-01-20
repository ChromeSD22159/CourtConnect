//
//  Repository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//

import Foundation
import SwiftData

@MainActor class Repository {
    var userRepository: UserRepository
    let chatRepository: ChatRepository
    let syncHistoryRepository: SyncHistoryRepository
    let container: ModelContainer
    
    init(type: RepositoryType) {
        let schema = Schema([
            UserProfile.self,
            Chat.self,
            SyncHistory.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: type == .preview ? true : false )
        
        let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        self.container = container
        
        self.userRepository = UserRepository(container: container)
        self.chatRepository = ChatRepository(container: container, type: type)
        self.syncHistoryRepository = SyncHistoryRepository(container: container, type: type)
    }
} 

