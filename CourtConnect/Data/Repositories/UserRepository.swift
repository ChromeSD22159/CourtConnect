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
class UserRepository: DatabaseProtocol, SupabaseRepositoryProtocol {
    let type: RepositoryType
    let container: ModelContainer
    let deviceToken = UIDevice.current.identifierForVendor!.uuidString
    let backendClient = BackendClient.shared
    
    init(type: RepositoryType) {
        self.type = type
         
        let schema = Schema([
            UserProfile.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: type == .preview ? true : false )
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration]) 
        } catch {
            fatalError("Could not create User DataBase Container: \(error)")
        }
    }
       
    /// LOGIN INTO SUPABASE
    func signIn(email:String, password: String) async throws -> User? {
        let response = try await backendClient.supabase.auth.signIn(email: email, password: password)
        return response.user
    }
    
    /// REGISTER AND LOGIN INTO SUPABASE
    func signUp(email:String, password: String) async throws -> User? {
        let response = try await backendClient.supabase.auth.signUp(email: email, password: password)
        return response.session?.user
    }
    
    /// LOGOUT FROM SUPABASE
    func signOut(user: User) async throws {
        try await backendClient.supabase.auth.signOut()
         
        try removeUserProfile(user: user)
    }
    
    /// CHECK IF LOGGEDIN AND SET USER / USERPROFILE
    func isAuthendicated(isComplete: (User?, UserProfile?) -> Void) async {
        for await state in backendClient.supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                if let user = state.session?.user {
                    do {
                        
                        try await syncUserProfile(user: user)
                        
                        let profile = try getUserProfileFromDatabase(user: user)
                        
                        isComplete( user, profile )
                    } catch {
                        isComplete( user, nil )
                    }
                } else {
                    isComplete( nil, nil )
                } 
            }
        }
    }
    
    func getUserProfileFromDatabase(user: User) throws -> UserProfile? {
        let predicate = #Predicate<UserProfile> {
            $0.userId == user.id.uuidString
        }
        
        let sortBy = [SortDescriptor(\UserProfile.createdAt, order: .reverse)]
        
        let fetchDescriptor = FetchDescriptor<UserProfile>(predicate: predicate, sortBy: sortBy)
         
        return try container.mainContext.fetch(fetchDescriptor).first
    }
    
    func syncUserProfile(user: User) async throws {
        let date: [UserProfile] = try await backendClient.supabase
            .from(DatabaseTables.userProfile.rawValue)
            .select("*")
            .eq("userId", value: user.id)
            .execute()
            .value 
            
        if let newProfile = date.first {
            try insertOrUpdate(profile: newProfile)
        }
    }
    
    private func insertOrUpdate(profile: UserProfile) throws {
        container.mainContext.insert(profile)
        try container.mainContext.save()
    }
    
    /// SAVE CHANGES LOCAL AND SEND TO SUPABASE
    func sendUserProfileToBackend(profile: UserProfile) async throws {
        guard type == .app else { return }
        
        try insertOrUpdate(profile: profile)
        
        try await backendClient.supabase
            .from(DatabaseTables.userProfile.rawValue)
            .upsert(profile, onConflict: "userId")
            .execute()
    }
    
    func removeUserProfile(user: User) throws {
        let predicate = #Predicate<UserProfile> {
            $0.id == user.id
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
    
    func setUserOnline(user: User, userProfile: UserProfile) async throws -> Bool {
        let userOnline = UserOnline(userId: user.id.uuidString, firstName: userProfile.firstName, lastName: userProfile.lastName, deviceToken: self.deviceToken)
        
        try await backendClient.supabase
            .from(DatabaseTables.userOnline.rawValue)
            .insert(userOnline)
            .execute()
        
        return await isRequestSuccessful(statusCode: 201)
    }
    
    func setUserOffline(user: User) async throws -> Bool {
         let query = try await backendClient.supabase
           .from(DatabaseTables.userOnline.rawValue)
           .delete()
           .match(["userId": user.id.uuidString, "deviceToken": self.deviceToken])
           .execute()

         // Check the response status code
         return await isRequestSuccessful(statusCode: query.response.statusCode)
    }
    
    func listenForOnlineUserComesOnline(completion: @escaping ([UserOnline]) -> Void) {
        let channelInsertUserOnline = backendClient.supabase.realtimeV2.channel("public:UserOnline:insert")
          
        let insertions = channelInsertUserOnline.postgresChange(InsertAction.self, table: SupabaseTable.userOnline.rawValue)
        Task {
            await channelInsertUserOnline.subscribe()
            for await _ in insertions {
                let list = try await getOnlineUserList()
                completion(list)
            }
        }
    }
    
    func listenForOnlineUserGoesOffline(completion: @escaping ([UserOnline]) -> Void) {
        let channelDeleteUserOnline = backendClient.supabase.realtimeV2.channel("public:UserOnline:delete")
         
        let deletions = channelDeleteUserOnline.postgresChange(DeleteAction.self, table: SupabaseTable.userOnline.rawValue)
        Task {
            await channelDeleteUserOnline.subscribe()
            for await _ in deletions {
                let list = try await getOnlineUserList()
                completion(list)
            }
        }
    }
    
    func getOnlineUserList() async throws -> [UserOnline] {
        let list: [UserOnline] = try await backendClient.supabase
            .from(DatabaseTables.userOnline.rawValue)
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
} 
