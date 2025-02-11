//
//  PlayerDashboardViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import Auth
import Foundation
import UIKit

@MainActor
@Observable class PlayerDashboardViewModel: AuthProtocol, SyncHistoryProtocol, ObservableObject {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccounts: [UserAccount] = []
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var isfetching: Bool = false
    
    var termine: [Termin] = []
    var attendancesTermines: [AttendanceTermin] = []
    
    var qrCode: UIImage?
    var isEnterCode = false
    
    var isAbsenseSheet = false
    var absenseDate = Date()
    
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
    
    func getTeamTermine() {
        do {
            guard let currentTeam = currentTeam else { throw TeamError.userHasNoTeam }
            termine = try repository.teamRepository.getTeamTermine(for: currentTeam.id)
        } catch {
            print(error)
        }
    }
    
    func getTerminAttendances() {
        do {
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            print(userAccount.id)
            let attandances = try repository.accountRepository.getAccountPendingAttendances(for: userAccount.id)
            print(attandances.count)
            for attandance in attandances {
                if let termines = try repository.teamRepository.getTermineBy(id: attandance.terminId) {
                    let attendanceTermin = AttendanceTermin(attendance: attandance, termin: termines)
                    
                    self.attendancesTermines.append(attendanceTermin)
                }
            }
        } catch {
            print(error)
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
    
    func absenceRegister() {
        Task {
            do {
                guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
                guard let teamId = currentTeam?.id else { throw TeamError.teamNotFound }
                let newAbsense = Absence(userAccountId: userAccount.id, teamId: teamId, date: absenseDate, createdAt: Date(), updatedAt: Date())
                try await repository.teamRepository.insertAbsense(absence: newAbsense, userId: userAccount.userId)
                self.isAbsenseSheet.toggle()
            } catch {
                print(error)
            }
        }
    }
    
    func updateTerminAttendance(attendance: Attendance) {
        defer { attendancesTermines.removeAll(where: { $0.attendance.terminId == attendance.terminId }) }
        Task {
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                try await repository.teamRepository.upsertTerminAttendance(attendance: attendance, userId: user.id)
            } catch {
                print(error)
            }
        }
    }
    
    func fetchDataFromRemote() {
        Task {
            do {
                if let userId = user?.id {
                    try await syncAllTables(userId: userId)
                    getTeam()
                    getTeamTermine()
                    getTerminAttendances()
                }
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
}
