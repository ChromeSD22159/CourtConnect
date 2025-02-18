//
//  AuthRepositoy.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import Foundation
import Auth
import SwiftData

@MainActor
class AuthRepositoy {
    let container: ModelContainer
    let backendClient: BackendClient
    
    init(container: ModelContainer) {
        self.container = container
        self.backendClient = BackendClient.shared
    }
    
    func resetPasswordForEmail(email:String) async throws {
        try await backendClient.supabase.auth.resetPasswordForEmail(email, redirectTo: URL(string: "CourtConnect://NewPassword"))
    }
    
    func updateUser(newPassword: String) async throws {
        try await backendClient.supabase.auth.update(user: UserAttributes(password: newPassword))
    }
    
    func getUser() -> User? {
        return LocalStorageService.shared.user
    }
    
    func getcurrentUserAccount() throws -> UserAccount? {
        guard
            let userAccountIdString = LocalStorageService.shared.userAccountId,
            let userAccountId = UUID(uuidString: userAccountIdString) else {
            return nil
        }
        let accountPredicate = #Predicate<UserAccount> { $0.id == userAccountId }
        return try container.mainContext.fetch(FetchDescriptor<UserAccount>(predicate: accountPredicate)).first
    }
    
    func getCurrentUserProfile() throws -> UserProfile? {
        guard let user = LocalStorageService.shared.user else { return nil }
        let accountPredicate = #Predicate<UserProfile> { $0.userId == user.id }
        return try container.mainContext.fetch(FetchDescriptor<UserProfile>(predicate: accountPredicate)).first
    }
}
