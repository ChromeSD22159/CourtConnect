//
//  TrainerDashboardViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import Auth
import Foundation
import UIKit

@MainActor
@Observable class TrainerDashboardViewModel: AuthProtocol, SyncHistoryProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccounts: [UserAccount] = []
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var isfetching: Bool = false
    
    var qrCode: UIImage?
    var isEnterCode = false
    
    func getTeam() {
        currentTeam = nil
        do {
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            guard let teamId = userAccount.teamId else { throw TeamError.teamNotFound }
            currentTeam = try repository.teamRepository.getTeam(for: teamId)
            
            readQRCode()
        } catch {
            currentTeam = nil
            qrCode = nil
        }
    }
    
    func deleteUserAccount() {
        Task {
            defer { try? setRandomAccount() }
            do {
                guard let currentAccount = userAccount else { throw UserError.userAccountNotFound }
                try repository.accountRepository.softDelete(item: currentAccount)
                try await repository.accountRepository.sendToBackend(item: currentAccount)
            } catch {
                if ErrorIdentifier.isConnectionTimedOut(error: error) {
                    print(error)
                }
            }
        }
    }
    
    func isAdmin() -> Bool {
        guard let userAccount = userAccount else { return false }
        return repository.accountRepository.isUserAdmin(account: userAccount)
    }
    
    func saveTermin(termin: Termin) {
        guard let userId = user?.id else { return }
        Task {
            defer { try? repository.accountRepository.insert(termin: termin, table: .termin, userId: userId) }
            do {
                try await SupabaseService.upsertWithOutResult(item: termin.toDTO(), table: .termin, onConflict: "id")
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
            }
        }
    }
    
    #warning("FUNCTIONIERT NICHT RICHTIG")
    func leaveTeam(role: UserRole) {
        do {
            guard let user = user else { throw UserError.userIdNotFound }
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            
            // wenn trainer
            if role == .trainer, let teamId = userAccount.teamId {
                guard try repository.teamRepository.getTeamAdmins(for: teamId).count > 1 else { throw TeamError.lastAdminCantLeave }
                
                if let myAdmin = try? repository.teamRepository.getAdmin(for: userAccount.id), let myMemberAccount = try repository.teamRepository.getMember(for: userAccount.id) {
                    try repository.teamRepository.softDelete(teamAdmin: myAdmin, userId: user.id)
                    try repository.teamRepository.softDelete(teamMember: myMemberAccount, userId: user.id)
                }
                
                userAccount.teamId = nil
                userAccount.updatedAt = Date()
                currentTeam = nil
                qrCode = nil
            }
            
            // wenn Spieler
            if role == .player, let myMemberAccount = try repository.teamRepository.getMember(for: userAccount.id) {
                print("myMemberAccount: \(myMemberAccount)")
                try repository.teamRepository.softDelete(teamMember: myMemberAccount, userId: user.id)
                
                userAccount.teamId = nil
                userAccount.updatedAt = Date()
                currentTeam = nil
                qrCode = nil
            }
        } catch {
            ErrorHandlerViewModel.shared.handleError(error: error)
        }
    }
    
    private func setRandomAccount() throws {
        guard let userId = user?.id else {  throw UserError.userIdNotFound }
        let newAccountList = try repository.accountRepository.getAllAccounts(userId: userId)
        userAccounts = newAccountList
        userAccount = newAccountList.first
        LocalStorageService.shared.userAccountId = userAccount?.id.uuidString
    }
    
    private func readQRCode() {
        if let currentTeam = currentTeam {
            qrCode = QRCodeHelper().generateQRCode(from: currentTeam.joinCode)
        }
    }
    
    func fetchDataFromRemote() {
        Task {
            do {
                if let userId = user?.id {
                    try await syncAllTables(userId: userId)
                    getTeam()
                }
            } catch {
                print(error)
            }
        }
    }
}
