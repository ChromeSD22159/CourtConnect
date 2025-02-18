//
//  LoginEntryViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI
import Auth

@Observable @MainActor class LoginEntryViewModel: AuthProtocol {
    var repository: BaseRepository = Repository.shared
    
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var isTextShowing = false
    var isSignInSheet = false
    var isSignUpSheet = false
    var isResetPassword = false
    
    func toogleText() {
        withAnimation(.easeInOut.delay(2.0)) {
            isTextShowing.toggle()
        }
    }
    
    func getAuth() {
        self.inizializeAuth()
    }
    
    func resetPassword() {
        
    }
}
