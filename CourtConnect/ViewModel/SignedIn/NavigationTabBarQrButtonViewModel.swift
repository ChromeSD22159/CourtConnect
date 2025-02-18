//
//  NavigationTabBarQrButtonViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 18.02.25.
//
import Observation
import Auth
import UIKit 
import SwiftUI

@Observable class NavigationTabBarQrButtonViewModel: AuthProtocol, QRCodeProtocol {
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var isSheet = false
    var joinCode: String = ""
    var qrCode: UIImage?
    private var currentBrightness: CGFloat?
    
    init() {
        inizializeAuth()
        generateQrCode()
    }
    
    func showSheet() {
        isSheet = true
        currentBrightness = UIScreen.main.brightness
        withAnimation {
            UIScreen.main.brightness = 1.0
        }
    }
    
    func closeSheet() {
        isSheet = false
        guard let currentBrightness = currentBrightness else { return }
        withAnimation {
            UIScreen.main.brightness = currentBrightness
        }
    }
}
