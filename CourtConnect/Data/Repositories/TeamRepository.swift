//
//  TeamRepository.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 24.01.25.
//
import SwiftData
import Foundation
import Supabase
 
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
        let fetchDescriptor = FetchDescriptor<Requests>(predicate: predicate)
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
    
    func softDelete(request: Requests) throws {
        request.updatedAt = Date()
        request.deletedAt = Date()
    }
    
    func removeTeamFromUserAccount(for userAccount: UserAccount) {
        userAccount.teamId = nil
        userAccount.updatedAt = Date()
    }
    
    func getPlayerStatistics(userAccountId: UUID, fetchLimit: Int = 7) throws -> [Statistic] {
        let predicate = #Predicate<Statistic>{ item in
            item.userAccountId == userAccountId && item.deletedAt == nil
        }
        
        var fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        fetchDescriptor.fetchLimit = fetchLimit
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    // MARK: - REMOTE
    func getTeamRemote(code: String) async throws -> TeamDTO? {
        return try await SupabaseService.getEquals(value: code, table: .team, column: "joinCode")
    }
    
    func joinTeamWithCode(_ code: String, userAccount: UserAccount) async throws {
        if let foundTeamDTO = try await getTeamRemote(code: code) {
            // CREATE MEMBER
            let newMember = TeamMember(userAccountId: userAccount.id, teamId: foundTeamDTO.id, role: userAccount.role, createdAt: Date(), updatedAt: Date())
            // INSER MEMBER REMOTE
            print("before insert") 
            let supabaseMember: TeamMemberDTO = try await SupabaseService.insert(item: newMember.toDTO(), table: .teamMember)
            print("after insert")
            // UPDATE LOCAL CURRENTUSERACCOUNT
            userAccount.teamId = newMember.teamId
            userAccount.updatedAt = Date()
            
            // INSERT LOCAL MEMBER
            try self.upsertLocal(item: foundTeamDTO.toModel())
            try self.upsertLocal(item: supabaseMember.toModel())
       
            print("before upsert")
            try await SupabaseService.upsertWithOutResult(item: userAccount.toDTO(), table: .userAccount, onConflict: "id")
            print("after upsert")
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
    
    // MARK: SOCKET
    func receiveTeamJoinRequests(complete: @escaping (Requests?) -> Void) {
        let channel = BackendClient.shared.supabase.channel("JoinRequests")
        
        let inserts = channel.postgresChange(InsertAction.self, schema: DatabaseTable.request.rawValue)
        
        Task {
            await channel.subscribe()
            
            for await insertion in inserts {
                do {
                    if let message: RequestsDTO = decodeDTO(from: insertion) { 
                        container.mainContext.insert(message.toModel())
                        try container.mainContext.save()
                        complete(message.toModel())
                    } else {
                        complete(nil)
                    }
                } catch {
                    complete(nil)
                }
            }
        }
    }
    
    func decodeDTO<T: Codable>(from insertion: InsertAction) -> T? {
        let decoder = JSONDecoder()
        
        let iso8601Formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // Mit Mikrosekunden
            "yyyy-MM-dd'T'HH:mm:ssXXXXX"         // Ohne Mikrosekunden
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            for format in iso8601Formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        
        do {
            return try insertion.decodeRecord(as: T.self, decoder: decoder)
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
}
