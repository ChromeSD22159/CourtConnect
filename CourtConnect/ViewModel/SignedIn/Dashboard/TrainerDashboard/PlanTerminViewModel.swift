//
//  PlanTerminViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI
import Auth

@Observable class PlanTerminViewModel: Sheet, AuthProtocol {
    var repository: BaseRepository = Repository.shared
     
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var isSheet = false
    var isLoading = false
    var animateOnAppear = false
    
    var title: String = ""
    var place: String = ""
    var infomation: String = ""
    var kind: TerminType = .training
    var date: Date = Date.now.addingTimeInterval(86400)
    var duration: TerminDuration = .oneTwenty
    
    init() {
        inizializeAuth()
    }
    
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
    
    func saveTermin() async throws {
        guard let userId = user?.id else { return }
        guard let userAccount = userAccount else { return }
        guard let termin = try await generateTermin(userAccount: userAccount) else { return }
         
        defer {
            try? repository.accountRepository.insert(termin: termin, table: .termin, userId: userId)
        }
        
        do { 
            try await SupabaseService.upsertWithOutResult(item: termin.toDTO(), table: .termin, onConflict: "id")
        } catch {
            ErrorHandlerViewModel.shared.handleError(error: error)
        }
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
