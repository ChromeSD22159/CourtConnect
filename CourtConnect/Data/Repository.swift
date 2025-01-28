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
    let accountRepository: AccountRepository
    let teamRepository: TeamRepository
    let syncHistoryRepository: SyncServiceRepository
    let container: ModelContainer
    
    init(type: RepositoryType) {
        let schema = Schema([
            Attendance.self,
            Chat.self,
            Document.self,
            Interest.self,
            Location.self,
            Requests.self,
            Statistic.self,
            SyncHistory.self,
            Team.self,
            TeamAdmin.self,
            TeamMember.self,
            Termine.self,
            UserAccount.self,
            UserProfile.self
        ])
        
        do {  
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: type == .preview ? true : false )
            
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = container
            
            self.userRepository = UserRepository(container: container)
            self.chatRepository = ChatRepository(container: container, type: type)
            self.accountRepository = AccountRepository(container: container, type: type)
            self.teamRepository = TeamRepository(container: container, type: type)
            self.syncHistoryRepository = SyncServiceRepository(container: container, type: type)
        } catch {
            fatalError("Cannot create Database \(error.localizedDescription)")
        }
    } 
}
