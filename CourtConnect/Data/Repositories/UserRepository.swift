//
//  UserRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
// 
import SwiftData
import Foundation
import Supabase
import FirebaseAuth
import UIKit

@MainActor
class UserRepository {
    let container: ModelContainer
   // let deviceToken: String
    let backendClient:BackendClient
    let firebaseAuth: Auth
     
    init(container: ModelContainer) {
        self.container = container
        self.backendClient = BackendClient.shared
        self.firebaseAuth = Auth.auth()
    }
       
    /// LOGIN INTO SUPABASE
    func signIn(email:String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await firebaseAuth.signIn(withEmail: email, password: password)
            return result.user
        } catch {
            throw error
        }
    }
    
    /// REGISTER AND LOGIN INTO SUPABASE
    func signUp(email:String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await firebaseAuth.createUser(withEmail: email, password: password)
            return result.user
        } catch {
            throw error
        }
    }
    
    /// LOGOUT FROM SUPABASE
    func signOut() async throws {
        try await backendClient.supabase.auth.signOut() 
    }
    
    /// CHECK IF LOGGEDIN AND SET USER / USERPROFILE
    func isAuthendicated() async throws -> FirebaseAuth.User? {
        return firebaseAuth.currentUser
    }
    
    func getUserProfileFromDatabase(userId: String) throws -> UserProfile? {
        let predicate = #Predicate<UserProfile> {
            $0.userId == userId
        }
        
        let sortBy = [SortDescriptor(\UserProfile.createdAt, order: .reverse)]
        
        let fetchDescriptor = FetchDescriptor<UserProfile>(predicate: predicate, sortBy: sortBy)
         
        return try container.mainContext.fetch(fetchDescriptor).first
    }
    
    func syncUserProfile(userId: String) async throws {
        let date: [UserProfile] = try await backendClient.supabase
            .from(DatabaseTables.userProfile.rawValue)
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
            .from(DatabaseTables.userProfile.rawValue)
            .upsert(profile, onConflict: "userId")
            .execute()
    }
    
    func removeUserProfile(user: FirebaseAuth.User) throws {
        let userId = user.uid
        let predicate = #Predicate<UserProfile> {
            $0.userId == userId
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
    
    func setUserOnline(user: FirebaseAuth.User, userProfile: UserProfile) async throws -> Bool {
        let apnsToken = ApnsMessaging.shared.apnsToken ?? ""
        let userOnline = UserOnline(userId: user.uid, firstName: userProfile.firstName, lastName: userProfile.lastName, deviceToken: apnsToken)
        
        try await backendClient.supabase
            .from(DatabaseTables.userOnline.rawValue)
            .insert(userOnline)
            .execute()
        
        return await isRequestSuccessful(statusCode: 201)
    }
    
    func setUserOffline(user: FirebaseAuth.User) async throws -> Bool {
         let apnsToken = ApnsMessaging.shared.apnsToken ?? ""
        
         let query = try await backendClient.supabase
           .from(DatabaseTables.userOnline.rawValue)
           .delete()
           .match(["userId": user.uid, "deviceToken": apnsToken])
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
    
    func deleteUserAccount() async throws { 
        try await firebaseAuth.currentUser?.delete()
    }
}

struct MockUser { 
    static let myUserProfile = UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!.uuidString, firstName: "Frederik", lastName: "Kohler", roleString: UserRole.player.rawValue, birthday: "22.11.1986")
    
    static let userList = [
        myUserProfile,
        UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!.uuidString, firstName: "Sabina", lastName: "Hodel", roleString: UserRole.player.rawValue, birthday: "21.06.1995"),
        UserProfile(userId: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!.uuidString, firstName: "Nico", lastName: "Kohler", roleString: UserRole.player.rawValue, birthday: "08.01.2010")
    ]
}
