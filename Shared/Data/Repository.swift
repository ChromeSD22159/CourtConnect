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
import Auth
 
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
    var authRepository: AuthRepositoy
    var userRepository: UserRepository
    var chatRepository: ChatRepository
    var accountRepository: AccountRepository
    var teamRepository: TeamRepository
    var terminRepository: TerminRepository
    var documentRepository: DocumentRepository
    var noteRepository: NoteRepository
    var syncHistoryRepository: SyncServiceRepository
    var container: ModelContainer
    
    init() {
        let _ = CacheConfig.shared
        
        let schema = Schema([
            Absence.self,
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
            UserProfile.self,
            Note.self
        ])
        
        let isStoredInMemoryOnly: Bool
        let modelConfiguration: ModelConfiguration
        
        if let infoDict = Bundle.main.infoDictionary, let isStoredInMemoryOnlyFromPlist = infoDict["isStoredInMemoryOnly"] as? Bool {
            isStoredInMemoryOnly = isStoredInMemoryOnlyFromPlist
            print("isStoredInMemoryOnlyFromPlist: \(isStoredInMemoryOnlyFromPlist)")
            
            modelConfiguration = ModelConfiguration(
                groupContainer: .identifier("group.CourtConnect")
            )
            
        } else {
            isStoredInMemoryOnly = true
            
            modelConfiguration = ModelConfiguration(
                isStoredInMemoryOnly: isStoredInMemoryOnly,
                groupContainer: .identifier("group.CourtConnect")
            )
        }
         
        do {
            let container = try ModelContainer(for: schema, configurations: modelConfiguration)
            self.container = container
            
            self.authRepository = AuthRepositoy(container: container)
            self.userRepository = UserRepository(container: container)
            self.chatRepository = ChatRepository(container: container)
            self.accountRepository = AccountRepository(container: container)
            self.teamRepository = TeamRepository(container: container)
            self.terminRepository = TerminRepository(container: container)
            self.syncHistoryRepository = SyncServiceRepository(container: container)
            self.documentRepository = DocumentRepository(container: container)
            self.noteRepository = NoteRepository(container: container)
        } catch {
            fatalError("Cannot create Database \(error)")
        }
    } 
} 
