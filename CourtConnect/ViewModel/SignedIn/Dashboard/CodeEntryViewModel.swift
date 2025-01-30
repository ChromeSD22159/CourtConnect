//
//  CodeEntryViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//
import Foundation 
 
@Observable class CodeEntryViewModel {
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    }
    
    var code: [Character] = []
    
    var message: String = " "

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
    
    func joinTeamWithCode(code: String, userAccount: UserAccount) async throws {
        Task {
            try await repository.teamRepository.joinTeamWithCode(code, userAccount: userAccount)
            
            try await repository.syncHistoryRepository.insertLastSyncTimestamp(for: .teamMember, userId: userAccount.userId)
        }
    }
}
