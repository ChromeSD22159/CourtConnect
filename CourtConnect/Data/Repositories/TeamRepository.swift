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
            team.id == teamId && team.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor).first
    }
    
    func getUserProfile(for userId: UUID) throws -> UserProfile? {
        let redicate = #Predicate<UserProfile> { user in
            user.id == userId
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
        let redicate = #Predicate<TeamMember> { teamMember in
            teamMember.teamId == teamId
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getTeamMembers(for teamId: UUID, role: UserRole) throws -> [TeamMember] {
        let roleString = role.rawValue
        let redicate = #Predicate<TeamMember> { teamMember in
            teamMember.teamId == teamId && teamMember.role == roleString && teamMember.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getTeamAdmins(for teamId: UUID) throws -> [TeamAdmin] {
        let redicate = #Predicate<TeamAdmin> { admin in
            admin.teamId == teamId
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getMembers(for teamId: UUID, role: UserRole) throws -> [TeamAdmin] {
        let roleString = role.rawValue
        let redicate = #Predicate<TeamAdmin> { teamMember in
            teamMember.teamId == teamId && teamMember.role == roleString && teamMember.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getMember(for userAccountId: UUID) throws -> TeamMember? {
        let redicate = #Predicate<TeamMember> { teamMember in
            teamMember.userAccountId == userAccountId && teamMember.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor).first
    }
    
    func getAdmin(for userAccountId: UUID) throws -> TeamAdmin? {
        let predicate = #Predicate<TeamAdmin> { teamMember in
            teamMember.userAccountId == userAccountId && teamMember.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        return try container.mainContext.fetch(fetchDescriptor).first
    }
     
    func getTeamRequests(teamId: UUID) throws -> [Requests] {
        let predicate = #Predicate<Requests> { $0.teamId == teamId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        return try container.mainContext.fetch(fetchDescriptor)
    } 
    
    func deleteLocalTeam(for team: Team) {
        container.mainContext.delete(team)
    }
    
    func softDelete(teamMember: TeamMember) throws {
        teamMember.updatedAt = Date()
        teamMember.deletedAt = Date()
        
        try upsertLocal(item: teamMember)
        
        Task {
            try await SupabaseService.upsertWithOutResult(item: teamMember.toDTO(), table: .teamMember, onConflict: "id")
        }
    }
    
    func softDelete(teamAdmin: TeamAdmin) throws {
        teamAdmin.updatedAt = Date()
        teamAdmin.deletedAt = Date()
        
        try upsertLocal(item: teamAdmin)
        
        Task {
            try await SupabaseService.upsertWithOutResult(item: teamAdmin.toDTO(), table: .teamAdmin, onConflict: "id")
        }
    }
    
    func softDelete(team: Team) throws {
        team.updatedAt = Date()
        team.deletedAt = Date()
        
        try upsertLocal(item: team)
        
        Task {
           try await SupabaseService.upsertWithOutResult(item: team.toDTO(), table: .team, onConflict: "id")
        }
    }
    
    func removeTeamFromUserAccount(for userAccount: UserAccount) {
        userAccount.teamId = nil
        userAccount.updatedAt = Date()
    }
    
    // MARK: - REMOTE
    func getTeamRemote(code: String) async throws -> TeamDTO? {
        return try await SupabaseService.getEquals(value: code, table: .team, column: "joinCode")
    }
    
    func joinTeamWithCode(_ code: String, userAccount: UserAccount) async throws {
        if let foundTeamDTO = try await getTeamRemote(code: code) {
            // CREATE MEMBER
            let newMember = TeamMember(userAccountId: userAccount.userId, teamId: foundTeamDTO.id, role: userAccount.role, createdAt: Date(), updatedAt: Date())
            // INSER MEMBER REMOTE
            let supabaseMember: TeamMemberDTO = try await SupabaseService.insert(item: newMember.toDTO(), table: .teamMember)
            // UPDATE LOCAL CURRENTUSERACCOUNT
            userAccount.teamId = newMember.teamId
            userAccount.updatedAt = Date()
            
            // INSERT LOCAL MEMBER
            try self.upsertLocal(item: foundTeamDTO.toModel())
            try self.upsertLocal(item: supabaseMember.toModel())
        } else {
            throw TeamError.noTeamFoundwithThisJoinCode
        }
    }
    
    func insertTeam(newTeam: Team, userId: UUID) async throws {
        let entry: TeamDTO = try await SupabaseService.insert(item: newTeam.toDTO(), table: .team)
         
        try self.upsertLocal(item: entry.toModel())
    }
    
    func insertTeamMember(newMember: TeamMember, userId: UUID) async throws {
        let entry: TeamMemberDTO = try await SupabaseService.insert(item: newMember.toDTO(), table: .teamMember)
         
        try self.upsertLocal(item: entry.toModel())
    }
    
    func insertTeamAdmin(newAdmin: TeamAdmin, userId: UUID) async throws {
        let entry: TeamAdminDTO = try await SupabaseService.insert(item: newAdmin.toDTO(), table: .teamAdmin)
         
        try self.upsertLocal(item: entry.toModel())
    }
    
    func searchTeamByName(name: String) async throws -> [TeamDTO] {
        return try await SupabaseService.search(name: name, table: DatabaseTable.team, column: "teamName")
    }
} 
