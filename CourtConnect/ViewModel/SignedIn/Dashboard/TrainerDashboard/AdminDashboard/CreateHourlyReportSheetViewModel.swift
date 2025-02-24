//
//  CreateHourlyReportSheetViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
//
import Auth
import Foundation
 
@Observable @MainActor class CreateHourlyReportSheetViewModel: AuthProtocol {
    
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var currentList: [TrainerSaleryData] = []
    
    var start: Date = Date().startOfMonth
    var end = Date().endOfMonth
    
    var isLoading: Bool = false
    var hourlyRate: Double
    
    init(hourlyRate: Double) {
        self.hourlyRate = hourlyRate
        inizializeAuth()
    }
    
    func getTrainerData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await Task.sleep(for: .seconds(1.5))
            let data: [UUID: Int] = try getloadTrainerData()
            var list: [UserProfile: Double] = [:]
            
            try data.forEach { (userAccount: UUID, minutes: Int) in
                if let existAccount = try repository.accountRepository.getAccount(id: userAccount),
                   let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: existAccount.userId) {
                    
                    let hours = roundMinutesToQuarterHours(minutes: minutes)
                    list[userProfile] = hours
                }
            }
            
            currentList = list.map {
                TrainerSaleryData(fullName: $0.key.fullName, hours: $0.value, hourlyRate: hourlyRate)
            }
        } catch {
            ErrorHandlerViewModel.shared.handleError(error: error)
        }
    }
    
    private func getloadTrainerData() throws -> [UUID: Int] {
        guard let team = currentTeam else { throw TeamError.teamNotFound }
        
        var trainer: [UUID: Int] = [:]
        let termine = try repository.terminRepository.getTeamTermineForDateRange(for: team.id, start: start, end: end)
        try termine.forEach { termin in
            
            let minutes = termin.durationMinutes
            
            let trainerTheyWasThere = try repository.teamRepository.getTrainersForTermineWhenIsConfirmed(terminId: termin.id)
            trainerTheyWasThere.forEach { attendance in
                let trainerId = attendance.userAccountId

                if let existingMinutes = trainer[trainerId] {
                    // Trainer ist bereits in der Liste, addiere die Minuten
                    trainer[trainerId] = existingMinutes + minutes
                } else {
                    // Trainer ist neu, füge ihn mit den Minuten hinzu
                    trainer[trainerId] = minutes
                }
            }
        }
        
        return trainer
    }
    
    private func roundMinutesToQuarterHours(minutes: Int) -> Double {
        let totalHours = Double(minutes) / 60.0
        let quarterHours = round(totalHours * 4.0) / 4.0
        return quarterHours
    }
}
