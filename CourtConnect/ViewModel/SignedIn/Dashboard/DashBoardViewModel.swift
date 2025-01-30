//
//  DashBoardViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation

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
        
        repository.teamRepository.removeTeamFromUserAccount(for: currentAccount)
        
        getTeam(for: currentAccount)
    }
    
    /// SOFT DELETE LOCAL ONLY
    func deleteUserAccount(for currentAccount: UserAccount?) throws {
        guard let currentAccount = currentAccount else { return }
        try repository.accountRepository.softDelete(item: currentAccount)
    }
    
    func deleteTeam(currentAccount: UserAccount?) {
        // getAll
    }
}
