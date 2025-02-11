//
//  EditTerminViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI
import Auth

@Observable class EditTerminViewModel: AuthProtocol, Sheet {
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var isSheet: Bool = false
    var isLoading = false
    var animateOnAppear = false
    
    var title: String
    var place: String
    var infomation: String
    var kind: TerminType
    var date: Date
    var duration: TerminDuration
    var termin: Termin
    
    init(isLoading: Bool = false, animateOnAppear: Bool = false, termin: Termin) {
        self.isLoading = isLoading
        self.animateOnAppear = animateOnAppear
        self.title = termin.title
        self.place = termin.place
        self.infomation = termin.infomation
        self.kind = TerminType(rawValue: termin.typeString)!
        self.date = termin.startTime
        self.duration = TerminDuration(rawValue: termin.durationMinutes) ?? .fifteen
        self.termin = termin
        
        self.inizializeAuth()
    }
    
    func deleteTermin() async throws {
        try await loadingManager {
            guard let user = user else { throw UserError.userIdNotFound }
            
            termin.updatedAt = Date()
            termin.deletedAt = Date()
            try repository.teamRepository.upsertLocal(item: termin, table: .termin, userId: user.id)
            
            try await SupabaseService.upsertWithOutResult(item: termin.toDTO(), table: .termin, onConflict: "id")
        }
    }
    
    func saveTermin() async throws {
        try await loadingManager {
            guard !title.isEmpty else { throw TerminError.missingTitle }
            guard !place.isEmpty else { throw TerminError.missingPlace }
            guard !infomation.isEmpty else { throw TerminError.missingInformation }
            guard let user = user else { throw UserError.userIdNotFound } 
            
            termin.title = title
            termin.place = place
            termin.infomation = infomation
            termin.typeString = kind.rawValue
            termin.durationMinutes = duration.durationMinutes
            termin.startTime = date
            termin.endTime = Calendar.current.date(byAdding: .minute, value: duration.durationMinutes, to: date)!
            termin.updatedAt = Date()
            
            try repository.teamRepository.upsertLocal(item: termin, table: .termin, userId: user.id)
            
            try await SupabaseService.upsertWithOutResult(item: termin.toDTO(), table: .termin, onConflict: "id")
        } 
    }
}
