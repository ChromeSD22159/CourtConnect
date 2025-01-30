//
//  CodeEntryViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import Foundation 
import SwiftUI

@Observable class CodeEntryViewModel {
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    var shake = false
    var code: [Character] = []
    var message: String = " "
    var numberOfShakes = 0.0
    
    var codeString: [String] {
        return code.map { String($0) }
    }
    
    func addDigit(_ digit: String) {
        if code.count < 6, let char = digit.first {
            code.append(char)
        }
    }

    func deleteLastDigit() {
        if !code.isEmpty {
            code.removeLast()
        }
    }
      
    func past() {
        code = []
        if let pasteboard = ClipboardHelper.past() {
            for char in pasteboard {
                code.append(char)
            }
        }
    }
    
    func joinTeamWithCode(userAccount: UserAccount) async throws {
        try await repository.teamRepository.joinTeamWithCode(codeString.joined(), userAccount: userAccount)
        
        try await repository.syncHistoryRepository.insertLastSyncTimestamp(for: .teamMember, userId: userAccount.userId)
    }
    
    func triggerShakeAnimation() {
        withAnimation {
            numberOfShakes = Double.random(in: 5.01...5.99)
        }
        
        numberOfShakes = 0
    }
}
