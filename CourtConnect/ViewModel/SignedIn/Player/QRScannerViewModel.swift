//
//  QRScannerViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 18.02.25.
//
import Auth
import Observation

@Observable @MainActor class QRScannerViewModel: AuthProtocol {
    var repository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
     
    var isShowingScanner = true
    var scannedText = ""
    
    init() {
        inizializeAuth()
    }
    
    func joinTeam(_ code: String) async throws {
        guard scannedText.count == 6 else { return }
        guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
        try await repository.teamRepository.joinTeamWithCode(scannedText, userAccount: userAccount)
    }
}
