//
//  SyncViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 16.02.25.
//
import Observation
import Auth
import Foundation
 
class SyncViewModel: AuthProtocol, SyncHistoryProtocol, ObservableObject {
    static let shared = SyncViewModel()
    
    var repository: BaseRepository = Repository.shared
 
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    @Published var isfetching = false
    
    func fetchDataFromRemote() {
        inizializeAuth()
        
        guard let user = user else { return }
        
        Task {
            isfetching = true
            defer {
                isfetching = false
            }
            do {
                try await syncAllTables(userId: user.id)
            } catch {
                print(error)
            }
        }
    }
    
    func fetchDataFromRemote(user: User) async throws {
        isfetching = true
        
        defer {
            isfetching = false
        }
        do {
            try await syncAllTables(userId: user.id)
        } catch {
            print(error)
        }
    } 
}
