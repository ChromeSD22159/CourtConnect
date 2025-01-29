//
//  TeamRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//

import SwiftData
import Foundation

@MainActor class TeamRepository {
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
     
    // MARK: - Local
    func upsertLocal<T: ModelProtocol>(item: T) throws {
        container.mainContext.insert(item)
        try container.mainContext.save()
    }
 
    func getTeam(for teamId: UUID) throws -> Team? {
        let redicate = #Predicate<Team> { team in
             team.id == teamId
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor).first
    }
      
    func getTeams() throws -> [Team] {
        let redicate = #Predicate<Team> { team in
             team.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getTeamMembers(for teamId: UUID) throws -> [TeamMember] {
        let redicate = #Predicate<TeamMember> { team in
             team.id == teamId
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getTeamMembers(for teamId: UUID, role: UserRole) throws -> [TeamMember] {
        let roleString = role.rawValue
        let redicate = #Predicate<TeamMember> { teamMember in
            teamMember.id == teamId && teamMember.role == roleString && teamMember.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getTeamAdmins(for teamId: UUID) throws -> [TeamAdmin] {
        let redicate = #Predicate<TeamAdmin> { team in
             team.id == teamId
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getMembers(for teamId: UUID, role: UserRole) throws -> [TeamAdmin] {
        let roleString = role.rawValue
        let redicate = #Predicate<TeamAdmin> { teamMember in
            teamMember.id == teamId && teamMember.role == roleString && teamMember.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
     
    // MARK: - REMOTE
    func getTeamRemote(code: String) async throws -> TeamDTO? {
        return try await SupabaseService.getEquals(value: code, table: .team, column: "joinCode")
    }
    
    func joinTeamWithCode(_ code: String, userAccount: UserAccount) async throws {
        if let foundTeamDTO = try await getTeamRemote(code: code) {
            let newMember = TeamMemberDTO(userId: userAccount.userId, teamId: foundTeamDTO.id, role: userAccount.role, createdAt: Date(), updatedAt: Date())
            
            let entry: TeamMemberDTO = try await SupabaseService.insert(item: newMember, table: .teamMember)
            
            try self.upsertLocal(item: entry.toModel())
        }
    }
    
    func insertTeam(newTeam: Team) async throws {
        let entry: TeamDTO = try await SupabaseService.insert(item: newTeam.toDTO(), table: .team)
        
        try self.upsertLocal(item: entry.toModel())
    }
    
    func insertTeamMember(newMember: TeamMember) async throws {
        let entry: TeamMemberDTO = try await SupabaseService.insert(item: newMember.toDTO(), table: .teamMember)
        
        try self.upsertLocal(item: entry.toModel())
    }
    
    func insertTeamAdmin(newAdmin: TeamAdmin) async throws {
        let entry: TeamAdminDTO = try await SupabaseService.insert(item: newAdmin.toDTO(), table: .teamAdmin)
        
        try self.upsertLocal(item: entry.toModel())
    }
    
    func searchTeamByName(name: String) async throws -> [TeamDTO] {
        return try await SupabaseService.search(name: name, table: DatabaseTable.team, column: "teamName")
    }
} 

@MainActor
@Observable class TeamViewModel: ObservableObject {
    var teamName = ""
    
    var searchTeamName = ""
    var foundTeams: [TeamDTO] = []
    
    let repository: BaseRepository
    
    init(repository: BaseRepository) {
        self.repository = repository
    } 
    
    func joinTeamWithCode(code: String, userAccount: UserAccount) throws {
        Task {
            try await repository.teamRepository.joinTeamWithCode(code, userAccount: userAccount)
            
            try repository.syncHistoryRepository.insertLastSyncTimestamp(for: .teamMember, userId: userAccount.userId)
        }
    }
    
    func searchTeam(string: String) {
        Task {
            do {
                foundTeams = try await repository.teamRepository.searchTeamByName(name: string)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func resetFoundTeams() {
        foundTeams = []
    }
}
