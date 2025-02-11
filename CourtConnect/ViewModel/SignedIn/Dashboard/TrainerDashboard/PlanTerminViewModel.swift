//
//  PlanTerminViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI

@Observable class PlanTerminViewModel: Sheet {
    var isSheet = false
    var isLoading = false
    var animateOnAppear = false
    
    var title: String = ""
    var place: String = ""
    var infomation: String = ""
    var kind: TerminType = .training
    var date: Date = Date.now.addingTimeInterval(86400)
    var duration: TerminDuration = .oneTwenty
    
    func generateTermin(userAccount: UserAccount) async throws -> Termin? {
        var newTermin: Termin?
        
        try await loadingManager {
            guard !title.isEmpty else { throw TerminError.missingTitle }
            guard !place.isEmpty else { throw TerminError.missingPlace }
            guard !infomation.isEmpty else { throw TerminError.missingInformation }
            guard let teamId = userAccount.teamId else { throw TerminError.missingTeamId }
            
            newTermin = Termin(
                teamId: teamId,
                title: title,
                place: place,
                infomation: infomation,
                typeString: kind.rawValue,
                durationMinutes: duration.durationMinutes,
                startTime: date,
                endTime: Calendar.current.date(byAdding: .minute, value: duration.durationMinutes, to: date)!,
                createdByUserAccountId: userAccount.id,
                createdAt: Date(),
                updatedAt: Date()
            )
            isSheet.toggle()
            resetStates()
        }
        
        return newTermin
    }
    
    func resetStates() {
        title = ""
        place = ""
        infomation = ""
        kind = .training
        date = Date()
        duration = .oneTwenty
    } 
} 
