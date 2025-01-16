//
//  UserRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
// 
import SwiftData
import Foundation
import Supabase
 
@Model class Item {
    var id: UUID
    var test: String
    
    init(id: UUID, test: String) {
        self.id = id
        self.test = test
    }
}

@MainActor
class UserRepository: DatabaseProtocol {
    let type: RepositoryType
    let container: ModelContainer

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
        try insertOrUpdate(profile: profile)
        
        try await backendClient.supabase
            .from(DatabaseTables.userProfile.rawValue)
            .upsert(profile, onConflict: "userId")
            .execute()
    }
    
    func userComeOnline(profile: UserProfile) async throws {
        profile.lastOnline = Date()
        try await sendUserProfileToBackend(profile: profile)
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
}
