//
//  Repository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import Foundation
import SwiftData
import SwiftUICore
 
@MainActor class RepositoryPreview: BaseRepository {
    static let shared: BaseRepository = RepositoryPreview()
 
    init() {
        super.init(type: .preview)
    }
}

@MainActor class Repository: BaseRepository {
    static let shared: BaseRepository = Repository()
 
    init() {
        super.init(type: .app)
    }
}

@MainActor class BaseRepository {
    var userRepository: UserRepository
    var chatRepository: ChatRepository
    var accountRepository: AccountRepository
    var teamRepository: TeamRepository
    var syncHistoryRepository: SyncServiceRepository
    var container: ModelContainer
    
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
        
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: type == .app ? false : true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = container
            
            self.userRepository = UserRepository(container: container)
            self.chatRepository = ChatRepository(container: container)
            self.accountRepository = AccountRepository(container: container)
            self.teamRepository = TeamRepository(container: container)
            self.syncHistoryRepository = SyncServiceRepository(container: container)
        } catch {
            if type == .app {
                fatalError("Cannot create Database \(error.localizedDescription)")
            } else {
                fatalError("Cannot create Preview Database \(error.localizedDescription)")
            }
        }
    }
}
