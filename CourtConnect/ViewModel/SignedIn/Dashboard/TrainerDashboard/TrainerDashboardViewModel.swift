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
@Observable class TrainerDashboardViewModel: AuthProtocol {
    var syncViewModel = SyncViewModel.shared
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccounts: [UserAccount] = []
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    var termine: [Termin] = [] 
    var isPlanAppointmentSheet = false
    var isDocumentSheet = false  
    var isEnterCode = false
    var requests = 0
    
    var attendancesTermines: [AttendanceTermin] = []
    
    init() {
        inizializeAuth()
        loadLocalData()
    }
    
    func loadLocalData() {
        getTeam()
        getTeamTermine()
        countRequests()
        getTerminAttendances()
    }
    
    func deleteUserAccount() {
        Task {
            defer { try? setRandomAccount() }
            do {
                guard let currentAccount = userAccount else { throw UserError.userAccountNotFound }
                try repository.accountRepository.softDelete(item: currentAccount)
                try await repository.accountRepository.sendToBackend(item: currentAccount)
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
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
            defer {
                try? repository.accountRepository.insert(termin: termin, table: .termin, userId: userId)
                loadLocalData()
            }
            do {
                try await SupabaseService.upsertWithOutResult(item: termin.toDTO(), table: .termin, onConflict: "id")
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
            }
        }
    }
    
    func fetchData() {
        Task {
            defer {
                loadLocalData()
            }
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                try await syncViewModel.fetchDataFromRemote(user: user)
            } catch {
                print(error)
            }
        }
    }
    
    #warning("FUNCTIONIERT NICHT RICHTIG")
    func leaveTeam(role: UserRole) {
        do {
            guard let user = user else { throw UserError.userIdNotFound }
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            
            // wenn trainer
            if role == .coach, let teamId = userAccount.teamId {
                guard try repository.teamRepository.getTeamAdmins(for: teamId).count > 1 else { throw TeamError.lastAdminCantLeave }
                
                if let myAdmin = try? repository.teamRepository.getAdmin(for: userAccount.id), let myMemberAccount = try repository.teamRepository.getMember(for: userAccount.id) {
                    try repository.teamRepository.softDelete(teamAdmin: myAdmin, userId: user.id)
                    try repository.teamRepository.softDelete(teamMember: myMemberAccount, userId: user.id)
                }
                
                userAccount.teamId = nil
                userAccount.updatedAt = Date()
                currentTeam = nil
            }
            
            // wenn Spieler
            if role == .player, let myMemberAccount = try repository.teamRepository.getMember(for: userAccount.id) { 
                try repository.teamRepository.softDelete(teamMember: myMemberAccount, userId: user.id)
                
                userAccount.teamId = nil
                userAccount.updatedAt = Date()
                currentTeam = nil
            }
        } catch {
            ErrorHandlerViewModel.shared.handleError(error: error)
        }
    }
    
    func updateTerminAttendance(attendance: Attendance) {
        Task {
            defer { loadLocalData() }
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                try await repository.teamRepository.upsertTerminAttendance(attendance: attendance, userId: user.id)
                
            } catch {
                print(error)
            }
        }
    }
     
    private func getTeam() {
        currentTeam = nil
        do {
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            guard let teamId = userAccount.teamId else { throw TeamError.teamNotFound }
            currentTeam = try repository.teamRepository.getTeam(for: teamId)
        } catch {
            currentTeam = nil
        }
    }
    
    private func setRandomAccount() throws {
        guard let userId = user?.id else {  throw UserError.userIdNotFound }
        let newAccountList = try repository.accountRepository.getAllAccounts(userId: userId)
        userAccounts = newAccountList
        userAccount = newAccountList.first
        LocalStorageService.shared.userAccountId = userAccount?.id.uuidString
    }
    
    private func getTeamTermine() {
        do {
            guard let currentTeam = currentTeam else { throw TeamError.userHasNoTeam }
            termine = try repository.terminRepository.getTeamTermine(for: currentTeam.id)
        } catch {
            print(error)
        }
    }
    
    private func getTerminAttendances() {
        do {
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            var attendancesTerminesTmp: [AttendanceTermin] = []
            
            let attandances = try repository.accountRepository.getAccountPendingAttendances(for: userAccount.id)
            for attandance in attandances {
                if let termine = try repository.terminRepository.getTermineBy(id: attandance.terminId) {
                    let attendanceTermin = AttendanceTermin(attendance: attandance, termin: termine)
                    attendancesTerminesTmp.append(attendanceTermin)
                }
            }
            attendancesTermines = attendancesTerminesTmp
        } catch {
            print(error)
        }
    }
    
    private func countRequests() {
        do {
            guard let currentTeam = currentTeam else { throw TeamError.teamNotFound }
            requests = try repository.teamRepository.getTeamRequests(teamId: currentTeam.id).count
        } catch {
            print(error)
        }
    }
}
