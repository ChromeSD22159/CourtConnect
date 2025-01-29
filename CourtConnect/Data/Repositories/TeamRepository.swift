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
    private func usertLocal(item: Team) throws {
        container.mainContext.insert(item)
        try container.mainContext.save()
    }
    
    private func usertLocal(item: TeamMember) throws {
        container.mainContext.insert(item)
        try container.mainContext.save()
    }
    
    private func usertLocal(item: TeamAdmin) throws {
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
        return try await backendClient.supabase
            .from(DatabaseTable.team.rawValue)
            .select()
            .eq("joinCode", value: code)
            .execute()
            .value
            
    }
    
    func joinTeamWithCode(_ code: String, userAccount: UserAccount) async throws {
        if let foundTeamDTO = try await getTeamRemote(code: code) {
            let newMember = TeamMemberDTO(userId: userAccount.userId, teamId: foundTeamDTO.id, role: userAccount.role, createdAt: Date(), updatedAt: Date())
            
            let entry: TeamMemberDTO = try await backendClient.supabase
                .from(DatabaseTable.teamMember.rawValue)
                .insert(newMember)
                .single()
                .execute()
                .value
            
            try self.usertLocal(item: entry.toModel())
        }
    }
    
    func insertTeam(newTeam: Team) async throws {
        let entry: TeamDTO = try await backendClient.supabase
            .from(DatabaseTable.teamMember.rawValue)
            .insert(newTeam.toDTO())
            .single()
            .execute()
            .value
        
        try self.usertLocal(item: entry.toModel())
    }
    
    func insertTeamMember(newMember: TeamMember) async throws {
        let entry: TeamMemberDTO = try await backendClient.supabase
            .from(DatabaseTable.teamMember.rawValue)
            .insert(newMember.toDTO())
            .single()
            .execute()
            .value
        
        try self.usertLocal(item: entry.toModel())
    }
    
    func insertTeamAdmin(newAdmin: TeamAdmin) async throws {
        let entry: TeamAdminDTO = try await backendClient.supabase
            .from(DatabaseTable.teamAdmin.rawValue)
            .insert(newAdmin.toDTO())
            .single()
            .execute()
            .value
        
        try self.usertLocal(item: entry.toModel())
    }
    
    func searchTeamByName(name: String) async throws -> [TeamDTO] {
        return try await backendClient.supabase
            .from(DatabaseTable.team.rawValue)
            .select()
            .like("teamName", pattern: "%" + name + "%") 
            .execute()
            .value
    }
}

@MainActor
@Observable class TeamViewModel {
    var teamName = ""
    
    var searchTeamName = ""
    var foundTeams: [TeamDTO] = []
    
    let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    func createTeam(userAccount: UserAccount, userProfile: UserProfile) async throws {
        let generatedCode = CodeGeneratorHelper.generateCode().map { String($0) }.joined()
        let now = Date()
        
        let newTeam = Team(teamName: teamName, createdBy: userProfile.fullName, headcoach: "", joinCode: generatedCode, createdAt: now, updatedAt: now)
        let newMember = TeamMember(userId: userAccount.id, teamId: newTeam.id, role: userAccount.role, createdAt: now, updatedAt: now)
        let newAdmin = TeamAdmin(teamId: newTeam.id, userId: userAccount.id, role: userAccount.role, createdAt: now, updatedAt: now)
        
        try await repository.teamRepository.insertTeam(newTeam: newTeam)
        try repository.syncHistoryRepository.insertLastSyncTimestamp(for: .team, userId: userAccount.userId)
        
        try await repository.teamRepository.insertTeamMember(newMember: newMember)
        try repository.syncHistoryRepository.insertLastSyncTimestamp(for: .team, userId: userAccount.userId)
        
        try await repository.teamRepository.insertTeamAdmin(newAdmin: newAdmin)
        try repository.syncHistoryRepository.insertLastSyncTimestamp(for: .team, userId: userAccount.userId)
    }
    
    func joinTeamWithCode(code: String, userAccount: UserAccount) throws {
        Task {
            try await repository.teamRepository.joinTeamWithCode(code, userAccount: userAccount)
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
