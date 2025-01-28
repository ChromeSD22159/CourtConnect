//
//  NavigationViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import Foundation

@Observable class NavigationViewModel {
    static let shared = NavigationViewModel()
    
    var current: NavigationTab = .home
    
    func navigateTo(_ site: NavigationTab) {
        current = site
    }
}
