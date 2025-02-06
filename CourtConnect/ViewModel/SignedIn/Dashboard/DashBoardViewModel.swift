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
    var termine: [Termin] = []
    var attendancesTermines: [AttendanceTermin] = []
    
    let repository: BaseRepository
    
    var isAbsenseSheet = false
    var absenseDate = Date()
    
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
    func leaveTeam(for currentAccount: UserAccount?, role: UserRole) throws {
        guard let currentAccount = currentAccount else { throw UserError.userAccountNotFound }
 
        // wenn trainer
        if role == .trainer, let teamId = currentAccount.teamId {
             
            guard try repository.teamRepository.getTeamAdmins(for: teamId).count > 1 else { throw TeamError.lastAdminCantLeave }
            
            if let myAdmin = try? repository.teamRepository.getAdmin(for: currentAccount.id), let myMemberAccount = try repository.teamRepository.getMember(for: currentAccount.id) {
                try repository.teamRepository.softDelete(teamAdmin: myAdmin)
                try repository.teamRepository.softDelete(teamMember: myMemberAccount)
            }
            
            currentAccount.teamId = nil
            currentAccount.updatedAt = Date()
            currentTeam = nil
            qrCode = nil
        }
         
        // wenn Spieler
        if role == .trainer, let myMemberAccount = try repository.teamRepository.getMember(for: currentAccount.id) {
            try repository.teamRepository.softDelete(teamMember: myMemberAccount)
            
            currentAccount.teamId = nil
            currentAccount.updatedAt = Date()
            currentTeam = nil
            qrCode = nil
        }
    }
    
    /// SOFT DELETE LOCAL ONLY
    func deleteUserAccount(for currentAccount: UserAccount?) async throws {
        guard let currentAccount = currentAccount else { return }
        try repository.accountRepository.softDelete(item: currentAccount)
        try await repository.accountRepository.sendToBackend(item: currentAccount)
    }
    
    func deleteTeam() throws {
        guard let currentTeam = currentTeam else { return }
        Task {
            try repository.teamRepository.softDelete(team: currentTeam)
        }
    }
    
    func startReceivingRequests() { 
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
    
    func absenceReport(for userAccount: UserAccount?) {
        Task {
            do {
                guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
                guard let teamId = currentTeam?.id else { throw TeamError.teamNotFound }
                let newAbsense = Absence(userAccountId: userAccount.id, teamId: teamId, date: absenseDate, createdAt: Date(), updatedAt: Date())
                try await repository.teamRepository.insertAbsense(absence: newAbsense)
                self.isAbsenseSheet.toggle()
            } catch {
                print(error)
            }
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
    
    func getTerminAttendances(for currentAccountId: UUID?) {
        do {
            guard let currentAccountId = currentAccountId else { throw UserError.userAccountNotFound }
            
            let attandances = try repository.accountRepository.getAccountPendingAttendances(for: currentAccountId)
            
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
    
    func updateTerminAttendance(attendance: Attendance) {
        defer { attendancesTermines.removeAll(where: { $0.attendance.terminId == attendance.terminId }) }
        Task {
            do {
                try await repository.teamRepository.upsertTerminAttendance(attendance: attendance)
            } catch {
                print(error)
            }
        }
    }
}
