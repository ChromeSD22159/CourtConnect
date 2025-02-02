//
//  PlanTerminViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI

@Observable class PlanTerminViewModel {
    var isSheet = false
    var isSheetAnimate = false
    
    var title: String = ""
    var place: String = ""
    var infomation: String = ""
    var kind: TerminType = .training
    var date: Date = Date()
    var duration: TerminDuration = .oneTwenty
    
    func generateTermin(userAccount: UserAccount) throws -> Termin {
        guard !title.isEmpty else { throw TerminError.missingTitle }
        guard !place.isEmpty else { throw TerminError.missingPlace }
        guard !infomation.isEmpty else { throw TerminError.missingInformation }
        guard let teamId = userAccount.teamId else { throw TerminError.missingTeamId }
        
        let newTermin = Termin(
            teamId: teamId,
            title: title,
            place: place,
            infomation: infomation,
            typeString: kind.rawValue,
            durationMinutes: duration.durationMinutes,
            date: date,
            createdByUserAccountId: userAccount.id,
            createdAt: Date(),
            updatedAt: Date()
        )
        isSheet.toggle()
        resetStates()
        return newTermin
    }
    
    func toggleSheet() {
        isSheet.toggle()
    }
    
    func toggleAnimate() {
        isSheetAnimate.toggle()
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
