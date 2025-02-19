//
//  UserRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
// 
import SwiftData
import Foundation
import Supabase
import UIKit

@MainActor
class UserRepository {
    let container: ModelContainer
    let deviceToken: String
    let backendClient: BackendClient
    
    init(container: ModelContainer) {
        self.container = container
        self.deviceToken = UIDevice.current.identifierForVendor!.uuidString
        self.backendClient = BackendClient.shared
    }
    
    /// LOGIN INTO SUPABASE
    func signIn(email:String, password: String) async throws -> User {
        let result = try await backendClient.supabase.auth.signIn(email: email, password: password)
        return result.user
    }
    
    /// REGISTER AND LOGIN INTO SUPABASE
    func signUp(email:String, password: String) async throws -> User {
        let result = try await backendClient.supabase.auth.signUp(email: email, password: password)
        return result.user
    }
    
    /// LOGOUT FROM SUPABASE
    func signOut() async throws {
        try await backendClient.supabase.auth.signOut()
        LocalStorageService.shared.userAccountId = nil
        LocalStorageService.shared.user = nil
    }
    
    /// CHECK IF LOGGEDIN AND SET USER / USERPROFILE
    func isAuthendicated() async -> User? {
        do {
            let auth = try await backendClient.supabase.auth.user()
            LocalStorageService.shared.user = auth
            return auth
        } catch {
            return LocalStorageService.shared.user
        }
    }
    
    func getUserProfileFromDatabase(userId: UUID) throws -> UserProfile? {
        let predicate = #Predicate<UserProfile> {
            $0.userId == userId
        }
        let fetchDescriptor = FetchDescriptor<UserProfile>(predicate: predicate)
        return try container.mainContext.fetch(fetchDescriptor).first
    }
    
    func getUserProfiles() throws -> [UserProfile] {
        let fetchDescriptor = FetchDescriptor<UserProfile>()
        return try container.mainContext.fetch(fetchDescriptor)
    }
     
    func getRequestedUser(accountId: UUID) async throws -> (UserAccount?, UserProfile?) {
        let accountPredicate = #Predicate<UserAccount> { $0.id == accountId }
        let userAccount = try container.mainContext.fetch(FetchDescriptor<UserAccount>(predicate: accountPredicate)).first

        guard let userAccount = userAccount else { return (nil, nil) }

        let userId = userAccount.userId
        let profilePredicate = #Predicate<UserProfile> { $0.userId == userId }
        let userProfile = try container.mainContext.fetch(FetchDescriptor<UserProfile>(predicate: profilePredicate)).first

        guard let userProfile = userProfile else { return (nil, nil)  }

        return (userAccount, userProfile)
    }
    
    func syncUserProfile(userId: UUID) async throws {
        let date: [UserProfileDTO] = try await backendClient.supabase
            .from(DatabaseTable.userProfile.rawValue)
            .select("*")
            .eq("userId", value: userId)
            .execute()
            .value 
            
        if let newProfile = date.first {
            try insertOrUpdate(profile: newProfile.toModel(), table: .userProfile, userId: userId)
        }
    }
    
    func insertOrUpdate(profile: UserProfile, table: DatabaseTable, userId: UUID) throws {
        container.mainContext.insert(profile) 
        let newSyncHistoryTimeStamp = SyncHistory(table: table, userId: userId)
        container.mainContext.insert(newSyncHistoryTimeStamp)
        
        try container.mainContext.save()
    }
    
    func sendUserProfileToBackend(profile: UserProfile) async throws {
        try insertOrUpdate(profile: profile, table: .userProfile, userId: profile.userId)
        try await backendClient.supabase
            .from(DatabaseTable.userProfile.rawValue)
            .upsert(profile.toDTO(), onConflict: "id")
            .execute()
    }
    
    func removeFcmToken(userProfile: UserProfile) async throws {
        let updates: [String: String?] = ["fcmToken": nil]
        try await backendClient.supabase // Separate Abfrage für fcmToken
            .from(DatabaseTable.userProfile.rawValue)
            .update(updates) // Setze fcmToken auf null
            .eq("id", value: userProfile.id) // oder userId, falls das dein Primärschlüssel ist
            .execute()
    }
    
    func removeUserProfile(user: User) throws {
        let predicate = #Predicate<UserProfile> {
            $0.userId == user.id
        }
        
        let fetchDescriptor = FetchDescriptor<UserProfile>(
            predicate: predicate,
            sortBy: [SortDescriptor(\UserProfile.createdAt, order: .reverse)]
        )
        
        let result = try container.mainContext.fetch(fetchDescriptor).first
        
        if let userProfile = result {
            container.mainContext.delete(userProfile)
        }
    }
    
    func setUserOnline(userId: UUID, userProfile: UserProfile) async throws -> Bool {
        let userOnline = UserOnlineDTO(userId: userId, firstName: userProfile.firstName, lastName: userProfile.lastName, deviceToken: self.deviceToken, timestamp: Date())
     
        return try await SupabaseService.upsert(item: userOnline, table: .userOnline, onConflict: "userId")
    }
    
    func setUserOffline(userId: UUID) async throws -> Bool {
        return try await SupabaseService.delete(table: .userOnline, match: ["userId": userId.uuidString, "deviceToken": self.deviceToken])
    }
    
    func listenForOnlineUserComesOnline(completion: @escaping (Result<[UserOnlineDTO], Error>) -> Void) {
        let channelInsertUserOnline = backendClient.supabase.realtimeV2.channel("public:UserOnline:insert")
          
        let insertions = channelInsertUserOnline.postgresChange(InsertAction.self, table: DatabaseTable.userOnline.rawValue)
        Task {
            await channelInsertUserOnline.subscribe()
            for await _ in insertions {
                let list = try await getOnlineUserList()
                completion(.success(list))
            }
        }
    }
    
    func listenForOnlineUserGoesOffline(completion: @escaping (Result<[UserOnlineDTO], Error>) -> Void) {
        let channelDeleteUserOnline = backendClient.supabase.realtimeV2.channel("public:UserOnline:delete")
         
        let deletions = channelDeleteUserOnline.postgresChange(DeleteAction.self, table: DatabaseTable.userOnline.rawValue)
        Task {
            await channelDeleteUserOnline.subscribe()
            for await _ in deletions {
                let list = try await getOnlineUserList()
                completion(.success(list))
            }
        }
    }
    
    func getOnlineUserList() async throws -> [UserOnlineDTO] {
        let list: [UserOnlineDTO] = try await SupabaseService.getAllFromTable(table: .userOnline)
         
        return uniqueOnlineUserList(list: list)
    }
    
    func deleteUser(user: User) async throws {
        try await backendClient.supabase
            .from(DatabaseTable.deletionRequest.rawValue)
            .upsert(DeletionRequestDTO(userId: user.id, createdAt: Date(), updatedAt: Date()), onConflict: "userId")
            .execute()
    }
    
    private func uniqueOnlineUserList(list: [UserOnlineDTO]) -> [UserOnlineDTO] {
        var uniqueUsers: [UserOnlineDTO] = []
        
        list.forEach { user in
            let result = uniqueUsers.filter {
                $0.deviceToken == user.deviceToken &&
                $0.userId == user.userId
            }
            
            if result.isEmpty {
                uniqueUsers.append(UserOnlineDTO(userId: user.userId, firstName: user.firstName, lastName: user.lastName, deviceToken: user.deviceToken, timestamp: user.timestamp))
            }
        }
        
        return uniqueUsers
    }
}
