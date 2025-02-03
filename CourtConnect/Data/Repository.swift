//
//  Repository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
//  xcrun simctl --set previews delete all

import Foundation
import SwiftData
import SwiftUICore
 
@MainActor class RepositoryPreview: BaseRepository {
    static let shared: BaseRepository = RepositoryPreview()
    
    override init() {
        super.init()
        initMock()
    }
    
    func initMock() {
        container.mainContext.insert(MockUser.myUserAccount)
    }
}

@MainActor class Repository: BaseRepository {
    static let shared: BaseRepository = Repository()
}

@MainActor class BaseRepository {
    var userRepository: UserRepository
    var chatRepository: ChatRepository
    var accountRepository: AccountRepository
    var teamRepository: TeamRepository
    var documentRepository: DocumentRepository
    var syncHistoryRepository: SyncServiceRepository
    var container: ModelContainer
    
    init() {
        let schema = Schema([
            Attendance.self,
            Chat.self,
            Document.self,
            Interest.self,
            Requests.self,
            Statistic.self,
            SyncHistory.self,
            Team.self,
            TeamAdmin.self,
            TeamMember.self,
            Termin.self,
            UserAccount.self,
            UserProfile.self
        ])
        
        let isStoredInMemoryOnly: Bool
        
        if let infoDict = Bundle.main.infoDictionary, let isStoredInMemoryOnlyFromPlist = infoDict["isStoredInMemoryOnly"] as? Bool {
            isStoredInMemoryOnly = isStoredInMemoryOnlyFromPlist
            print("isStoredInMemoryOnlyFromPlist: \(isStoredInMemoryOnlyFromPlist)")
        } else {
            isStoredInMemoryOnly = true
        }
         
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
         
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = container
            
            self.userRepository = UserRepository(container: container)
            self.chatRepository = ChatRepository(container: container)
            self.accountRepository = AccountRepository(container: container)
            self.teamRepository = TeamRepository(container: container)
            self.syncHistoryRepository = SyncServiceRepository(container: container)
            self.documentRepository = DocumentRepository(container: container)
        } catch {
            fatalError("Cannot create Database \(error)")
        }
    }
}
