//
//  DashBoardViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation 
import UIKit

@MainActor
@Observable class DashBoardViewModel: ObservableObject {
    var currentTeam: Team?
    
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    func getTeam(for currentAccount: UserAccount?) {
        guard let currentUser = currentAccount, let teamId = currentUser.teamId else { return } 
        do {
            currentTeam = try repository.teamRepository.getTeam(for: teamId)
        } catch {
            currentTeam = nil
        }
    }
    
    /// SOFT DELETE LOCAL ONLY
    func leaveTeam(for currentAccount: UserAccount?) throws {
        guard let currentAccount = currentAccount else { return }
         
        if let myAdmin = try repository.teamRepository.getAdmin(for: currentAccount.userId) {
            try repository.teamRepository.softDelete(teamAdmin: myAdmin)
        }
        
        if let myMemberAccount = try repository.teamRepository.getMember(for: currentAccount.userId) {
            try repository.teamRepository.softDelete(teamMember: myMemberAccount)
        }
        
        currentAccount.teamId = nil
        currentAccount.updatedAt = Date()
        
        currentTeam = nil 
    }
    
    /// SOFT DELETE LOCAL ONLY
    func deleteUserAccount(for currentAccount: UserAccount?) async throws {
        guard let currentAccount = currentAccount else { return }
        // TODO: delete all UserAccount Data
        try repository.accountRepository.softDelete(item: currentAccount)
        try await repository.accountRepository.sendToBackend(item: currentAccount)
    }
    
    func deleteTeam(currentAccount: UserAccount?) {
        // getAll
    }
    
    func startReceivingRequests() {
        print("Start RECEIVING")
        repository.teamRepository.receiveTeamJoinRequests { request in
            
        }
    }
    
    func saveTermin(termin: Termin) {
        repository.accountRepository.insert(termin: termin)
        
        Task {
            do {
                try await SupabaseService.upsertWithOutResult(item: termin.toDTO(), table: .termin, onConflict: "id")
            } catch {
                print(error)
            }
        }
    }
}
