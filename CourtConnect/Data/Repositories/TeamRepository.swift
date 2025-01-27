//
//  TeamRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//

import SwiftData
import Foundation

@MainActor class TeamRepository {
    
    var backendClient = BackendClient.shared
    var container: ModelContainer
    
    init(container: ModelContainer, type: RepositoryType) {
        self.container = container
    }
    
    // MARK: - Local
    func usert(item: Team) throws {
        container.mainContext.insert(item)
        try container.mainContext.save()
    }

    func softDelete(item: Team) throws {
        item.updatedAt = Date()
        item.deletedAt = Date()
        
        try usert(item: item)
    }
    
    func debugDelete() throws {
        let fetchDescruptor = FetchDescriptor<Team>()
        let result = try container.mainContext.fetch(fetchDescruptor)
        try result.forEach { item in
            container.mainContext.delete(item)
            try container.mainContext.save()
        }
    }
    
    // MARK: SYNCING
    func sendUpdatedAfterLastSyncToBackend(userId: String, lastSync: Date) async {
        Task {
            do {
                try await Task.sleep(for: .seconds(1))
                
                let predicate = #Predicate<Team> { $0.updatedAt > lastSync }
                let fetchDescriptor = FetchDescriptor<Team>(predicate: predicate)
                let result = try container.mainContext.fetch(fetchDescriptor)

                for team in result {
                    try await self.sendToBackend(item: team)
                }
            } catch {
                print("cannot send: \(error)")
            }
        }
    }
    
    func sendToBackend(item: Team) async throws { 
         try await backendClient.supabase
            .from(DatabaseTable.team.rawValue)
            .upsert(item.toTeamDTO(), onConflict: "id")
            .execute()
            .value
    }
    
    func fetchFromServer(after: Date) async throws -> [TeamDTO] {
        return try await backendClient.supabase
            .from(DatabaseTable.team.rawValue)
            .select()
            .gte("updatedAt", value: after)
            .execute()
            .value
    }
}
