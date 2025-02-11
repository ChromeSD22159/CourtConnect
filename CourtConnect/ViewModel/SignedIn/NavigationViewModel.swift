//
//  NavigationViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import Foundation
import Auth

@Observable class NavigationViewModel: AuthProtocol, ObservableObject {
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    static let shared = NavigationViewModel()
    
    var current: NavigationTab = .home
    
    func navigateTo(_ site: NavigationTab) {
        current = site
    }
}
