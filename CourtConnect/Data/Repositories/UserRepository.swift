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
        LocalStorageService.shared.user = nil
    }
    
    /// CHECK IF LOGGEDIN AND SET USER / USERPROFILE
    func isAuthendicated() async -> User? {
        do {
            return try await backendClient.supabase.auth.user()
        } catch {
            return LocalStorageService.shared.user
        }
    }
    
    func getUserProfileFromDatabase(userId: UUID) throws -> UserProfile? {
        let predicate = #Predicate<UserProfile> {
            $0.userId == userId
        }
        
        let sortBy = [SortDescriptor(\UserProfile.createdAt, order: .reverse)]
        
        let fetchDescriptor = FetchDescriptor<UserProfile>(predicate: predicate, sortBy: sortBy)
         
        return try container.mainContext.fetch(fetchDescriptor).first
    }
     
    func syncUserProfile(userId: UUID) async throws {
        let date: [UserProfile] = try await backendClient.supabase
            .from(DatabaseTable.userProfile.rawValue)
            .select("*")
            .eq("userId", value: userId)
            .execute()
            .value 
            
        if let newProfile = date.first {
            try insertOrUpdate(profile: newProfile)
        }
    }
    
    func insertOrUpdate(profile: UserProfile) throws {
        container.mainContext.insert(profile)
        try container.mainContext.save()
    }
    
    /// SAVE CHANGES LOCAL AND SEND TO SUPABASE
    func sendUserProfileToBackend(profile: UserProfile) async throws {
        try insertOrUpdate(profile: profile)
        
        try await backendClient.supabase
            .from(DatabaseTable.userProfile.rawValue)
            .upsert(profile, onConflict: "userId")
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
        let userOnline = UserOnline(userId: userId, firstName: userProfile.firstName, lastName: userProfile.lastName, deviceToken: self.deviceToken)
        
        try await backendClient.supabase
            .from(DatabaseTable.userOnline.rawValue)
            .insert(userOnline)
            .execute()
        
        return await isRequestSuccessful(statusCode: 201)
    }
    
    func setUserOffline(userId: UUID) async throws -> Bool {
         let query = try await backendClient.supabase
            .from(DatabaseTable.userOnline.rawValue)
           .delete()
           .match(["userId": userId.uuidString, "deviceToken": self.deviceToken])
           .execute()

         // Check the response status code
         return await isRequestSuccessful(statusCode: query.response.statusCode)
    }
    
    func listenForOnlineUserComesOnline(completion: @escaping (Result<[UserOnline], Error>) -> Void) {
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
    
    func listenForOnlineUserGoesOffline(completion: @escaping (Result<[UserOnline], Error>) -> Void) {
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
    
    func getOnlineUserList() async throws -> [UserOnline] {
        let list: [UserOnline] = try await backendClient.supabase
            .from(DatabaseTable.userOnline.rawValue)
            .select()
            .execute()
            .value
        
        var uniqueUsers: [UserOnline] = []
        
        list.forEach { user in
            let result = uniqueUsers.filter {
                $0.deviceToken == user.deviceToken &&
                $0.userId == user.userId
            }
            
            if result.isEmpty {
                uniqueUsers.append(UserOnline(userId: user.userId, firstName: user.firstName, lastName: user.lastName, deviceToken: user.deviceToken, timestamp: user.timestamp))
            }
        }
        
        return uniqueUsers
    }
    
    func isRequestSuccessful(statusCode: Int) async -> Bool {
        return (200...299).contains(statusCode)
    }
    
    func deleteUserAccount(user: User) async throws {
        try await backendClient.supabase
            .from(DatabaseTable.deletionRequest.rawValue)
            .upsert(DeletionRequestDTO(userId: user.id), onConflict: "userId")
            .execute()
    }
}
