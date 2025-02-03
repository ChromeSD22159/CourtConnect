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
    var qrCode: UIImage?
    
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    func getTeam(for currentAccount: UserAccount?) {
        guard let currentUser = currentAccount, let teamId = currentUser.teamId else { return } 
        do {
            currentTeam = try repository.teamRepository.getTeam(for: teamId)
            
            readQRCode()
        } catch {
            currentTeam = nil
            qrCode = nil
        }
    }
    
    func readQRCode() {
        if let currentTeam = currentTeam {
            qrCode = QRCodeHelper().generateQRCode(from: currentTeam.joinCode)
        }
    }
    
    /// SOFT DELETE LOCAL ONLY
    func leaveTeam(for currentAccount: UserAccount?) throws {
        guard let currentAccount = currentAccount else { throw UserError.userAccountNotFound }
         
        if let myAdmin = try? repository.teamRepository.getAdmin(for: currentAccount.id) {
            try repository.teamRepository.softDelete(teamAdmin: myAdmin)
        }
        
        print(currentAccount)
        if let myMemberAccount = try repository.teamRepository.getMember(for: currentAccount.id) {
            print(myMemberAccount)
            try repository.teamRepository.softDelete(teamMember: myMemberAccount)
        }
        
        currentAccount.teamId = nil
        currentAccount.updatedAt = Date()
        
        currentTeam = nil
        qrCode = nil
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
        // TODO: print("Start RECEIVING")
        repository.teamRepository.receiveTeamJoinRequests { _ in }
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
