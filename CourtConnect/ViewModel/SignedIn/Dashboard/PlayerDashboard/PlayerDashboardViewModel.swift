//
//  PlayerDashboardViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import Auth
import Foundation
import UIKit
import Combine

struct DateRange {
    var start: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    var end: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
}
 
@Observable class PlayerDashboardViewModel: AuthProtocol, QRCodeProtocol, ObservableObject {
    var syncViewModel = SyncViewModel.shared
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccounts: [UserAccount] = []
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team? 
    
    var termine: [Termin] = []
    var attendancesTermines: [AttendanceTermin] = []
    
    var qrCode: UIImage?
    var joinCode: String = ""
    var isEnterCode = false
    
    var isAbsenseSheet = false
    var startDate = Date.now.addingTimeInterval(86400)
    var endDate = Date.now.addingTimeInterval(86400)
    let range = Date.now...Date.now.addingTimeInterval(86400 * 14)
    
    init() {
        inizializeAuth()
        loadLocalData()
        generateQrCode()
    }
    
    func loadLocalData() {
        getTeam()
        getTeamTermine()
        getTerminAttendances()
    }
    
    func deleteUserAccount() {
        Task {
            defer { try? setRandomAccount() }
            do {
                guard let currentAccount = userAccount else { throw UserError.userAccountNotFound }
                try repository.accountRepository.softDelete(item: currentAccount)
                try await repository.accountRepository.sendToBackend(item: currentAccount)
                loadLocalData()
            } catch {
                if ErrorIdentifier.isConnectionTimedOut(error: error) {
                    print(error)
                }
            }
        }
    }
    
    func absenceRegister() {
        Task {
            defer { loadLocalData() }
            do {
                guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
                guard let teamId = currentTeam?.id else { throw TeamError.teamNotFound }
                let newAbsense = Absence(userAccountId: userAccount.id, teamId: teamId, startDate: startDate, endDate: endDate, createdAt: Date(), updatedAt: Date())
                try await repository.teamRepository.insertAbsense(absence: newAbsense, userId: userAccount.userId)
                self.isAbsenseSheet.toggle()
            } catch {
                print(error)
            }
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
    
    func fetchData() {
        Task {
            defer { loadLocalData() }
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                try await syncViewModel.fetchDataFromRemote(user: user)
            } catch {
                print(error)
            }
        }
    }
    
    private func setRandomAccount() throws {
        guard let userId = user?.id else {  throw UserError.userIdNotFound }
        let newAccountList = try repository.accountRepository.getAllAccounts(userId: userId)
        userAccounts = newAccountList
        userAccount = newAccountList.first
        LocalStorageService.shared.userAccountId = userAccount?.id.uuidString
    }
    
    private func getTeam() {
        currentTeam = nil
        do {
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            guard let teamId = userAccount.teamId else { throw TeamError.teamNotFound }
            currentTeam = try repository.teamRepository.getTeam(for: teamId)
            
            generateQrCode()
        } catch {
            currentTeam = nil
            qrCode = nil
        }
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
                qrCode = nil
            }
            
            // wenn Spieler
            if role == .player, let myMemberAccount = try repository.teamRepository.getMember(for: userAccount.id) {
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
}
