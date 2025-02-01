//
//  CourtConnectTests.swift
//  CourtConnectTests
//
//  Created by Frederik Kohler on 11.01.25.
//
import Supabase
import Testing
@testable import CourtConnect
import Foundation

@MainActor
struct CourtConnectTests {
    let repository: BaseRepository
    let userAccount = MockUser.myUserAccount
    let userProfile = MockUser.myUserProfile
    
    init() {
        repository = Repository.shared
    }
    
    @Test func setSupaseUserOnlineAndOffline() async throws {
        let success = try await repository.userRepository.setUserOnline(userId: userAccount.userId, userProfile: userProfile)
        
        #expect(success == true) 
    }
    
    @Test func setSupaseUserOffline() async throws {
        let isDeletet = try await repository.userRepository.setUserOffline(userId: userAccount.userId)
        
        #expect(isDeletet == true)
    }
    
    @Test func deleteUserAccount() async throws {
        let user = User(id: UUID(), appMetadata: [:], userMetadata: [:], aud: "", createdAt: Date(), updatedAt: Date())
        try await repository.userRepository.deleteUserAccount(user: user)
    }
}
