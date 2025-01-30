//
//  SupabaseService.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 29.01.25.
//

import Foundation
import Realtime

struct SupabaseService {
    static func search<T: DTOProtocol>(name: String, table: DatabaseTable, column: String) async throws -> [T] {
        return try await BackendClient.shared.supabase
            .from(table.rawValue)
            .select()
            .like(column, pattern: "%" + name + "%")
            .execute()
            .value
    }
    
    static func insert<T: DTOProtocol>(item: T, table: DatabaseTable) async throws -> T {
        return try await BackendClient.shared.supabase
            .from(table.rawValue)
            .insert(item)
            .select()
            .single()
            .execute()
            .value
    }
    
    static func insert<T: DTOProtocol>(item: T, table: DatabaseTable) async throws -> Bool {
        let response = try await BackendClient.shared.supabase
            .from(table.rawValue)
            .insert(item)
            .execute()
        
        return isRequestSuccessful(statusCode: response.response.statusCode)
    }
    
    static func getEquals<T: DTOProtocol>(value: String, table: DatabaseTable, column: String) async throws -> T? { 
        let result: [T] = try await BackendClient.shared.supabase
                .from(table.rawValue)
                .select()
                .eq(column, value: value)
                .execute()
                .value
            
        return result.first
    }
    
    static func getGreaterThan<T: DTOProtocol>(table: DatabaseTable, column: String = "updatedAt", lastSync: Date) async throws -> [T] {
        return try await BackendClient.shared.supabase
            .from(table.rawValue)
            .select()
            .gte(column, value: lastSync)
            .execute()
            .value
    }
    
    static func upsert<T: DTOProtocol>(item: T, table: DatabaseTable, onConflict: String) async throws -> T {
        return try await BackendClient.shared.supabase
            .from(table.rawValue)
            .upsert(item, onConflict: onConflict)
            .execute()
            .value
    }
    
    static func upsertWithOutResult<T: DTOProtocol>(item: T, table: DatabaseTable, onConflict: String) async throws {
         try await BackendClient.shared.supabase
            .from(table.rawValue)
            .upsert(item, onConflict: onConflict)
            .execute()
            .value
    }
    
    static func upsert<T: DTOProtocol>(item: T, table: DatabaseTable, onConflict: String) async throws -> Bool {
        let result = try await BackendClient.shared.supabase
            .from(table.rawValue)
            .upsert(item, onConflict: onConflict)
            .execute()
        
        return isRequestSuccessful(statusCode: result.response.statusCode)
    }
    
    static func delete(table: DatabaseTable, match: [String:String]) async throws -> Bool {
        let response = try await BackendClient.shared.supabase
           .from(table.rawValue)
           .delete()
           .match(match)
           .execute()
        
        return isRequestSuccessful(statusCode: response.response.statusCode)
    }
    
    static func getAllFromTable<T: DTOProtocol>(table: DatabaseTable) async throws -> [T] {
        return try await BackendClient.shared.supabase
            .from(table.rawValue)
            .select()
            .execute()
            .value
    }
    
    static func getAllFromTable<T: DTOProtocol>(table: DatabaseTable, match: [String:String]) async throws -> [T] {
        var query = BackendClient.shared.supabase.from(table.rawValue).select()

        for (key, value) in match {
            query = query.eq(key, value: value) 
        }

        return try await query.execute().value
    } 
    
    static func isRequestSuccessful(statusCode: Int) -> Bool {
        return (200...299).contains(statusCode)
    }
}
