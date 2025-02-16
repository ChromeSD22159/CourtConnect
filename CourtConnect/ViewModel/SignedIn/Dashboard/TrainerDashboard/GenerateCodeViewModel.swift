//
//  GenerateCodeViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import Foundation
import Auth

@Observable @MainActor class GenerateCodeViewModel: AuthProtocol {
    var isLoading: Bool = false
    
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var code: [Character] = [] 
    var message: String = " "
    var codeString: [String] {
        return code.map { String($0) }
    }
    
    init() {
        inizializeAuth()
        
        Task {
            try await Task.sleep(for: .seconds(0.5))
            generateCode()
        }
    }
    
    func copy() {
        guard !code.isEmpty else {
            message = "No Code generated"
            
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false , block: { [self]_ in 
                DispatchQueue.main.async { // Update message on the main thread
                    self.message = ""
                }
            })
            return
        }
        
        ClipboardHelper.copy(text: codeString.joined())
    }
    
    func generateCode() {
        Task {
            code = []
            let generated = CodeGeneratorHelper.generateCode()
            for char in generated {
                code.append(char)
                try await Task.sleep(for: .seconds(0.1))
            }
        }
    }
    
    func updateTeamCode() async throws {
        guard let user = user else { throw UserError.userIdNotFound }
        guard let currentTeam = currentTeam else { throw TeamError.teamNotFound }
        defer { repository.teamRepository.upsertlocal(item: currentTeam, table: .team, userId: user.id) }
        do {
            currentTeam.joinCode = code.map { String($0) }.joined()
            currentTeam.updatedAt = Date()
            
            try await repository.teamRepository.upsertTeamRemote(team: currentTeam)
            
            repository.teamRepository.upsertlocal(item: currentTeam, table: .team, userId: user.id)
        } catch {
            throw error
        }
    } 
}
