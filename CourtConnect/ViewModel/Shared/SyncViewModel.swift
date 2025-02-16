//
//  SyncViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import Foundation
import Auth

@Observable class SyncViewModel: AuthProtocol, SyncHistoryProtocol {
    
    static let shared = SyncViewModel()
    
    var repository: BaseRepository = Repository.shared
    
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    var isfetching: Bool = false
 
    func fetchDataFromRemote() {
        inizializeAuth()
        
        guard let user = user else { return }
        
        Task {
            isfetching = true
            defer { isfetching = false }
            do {
                try await syncAllTables(userId: user.id)
            } catch {
                print(error)
            }
        }
    }
}
