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
    func upsertLocal<T: ModelProtocol>(item: T, table: DatabaseTable, userId: UUID) throws {
        container.mainContext.insert(item)
        let newSyncHistoryTimeStamp = SyncHistory(table: table, userId: userId)
        container.mainContext.insert(newSyncHistoryTimeStamp)
        try container.mainContext.save() 
    }
    
    func upsertlocal<T: ModelProtocol>(item: T, table: DatabaseTable, userId: UUID) {
        do {
            container.mainContext.insert(item)
             
            let newSyncHistoryTimeStamp = SyncHistory(table: table, userId: userId)
            container.mainContext.insert(newSyncHistoryTimeStamp)
            
            try container.mainContext.save()
        } catch {
            print(error)
        }
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
            user.id == userId && user.deletedAt == nil
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
    
    func getAllTeamsAsc() throws -> [TeamDTO] {
        let redicate = #Predicate<Team> { team in
             team.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate, sortBy: [SortDescriptor(\.teamName, order: .forward)])
        
        return try container.mainContext.fetch(fetchDescriptor).map { $0.toDTO() }
    }
    
    func getTeamAbsense(for teamId: UUID) throws -> [Absence] {
        let redicate = #Predicate<Absence> { absence in
            absence.teamId == teamId && absence.deletedAt == nil
        }
        let fetchDescriptor = FetchDescriptor(predicate: redicate)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getTeamFutureAbsense(for teamId: UUID) throws -> [Absence] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let redicate = #Predicate<Absence> { absence in
            absence.teamId == teamId && absence.deletedAt == nil && absence.startDate >= startOfDay
        }
        let sort = [SortDescriptor(\Absence.startDate, order: .forward)]
        let fetchDescriptor = FetchDescriptor(predicate: redicate, sortBy: sort)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getTeamMembers(for teamId: UUID) throws -> [TeamMember] {
        let redicate = #Predicate<TeamMember> { teamMember in
            teamMember.teamId == teamId && teamMember.deletedAt == nil
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
            admin.teamId == teamId && admin.deletedAt == nil
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
     
    func getMemberStatistic(for userAccountId: UUID) throws -> [Statistic] {
        let predicate = #Predicate<Statistic> { $0.userAccountId == userAccountId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let statistic = try container.mainContext.fetch(fetchDescriptor)
        return statistic
    }
    
    func getMemberAvgStatistic(for userAccountId: UUID) throws -> MemberStatistic? {
        let predicate = #Predicate<Statistic> { $0.userAccountId == userAccountId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let statistics = try container.mainContext.fetch(fetchDescriptor)
        let items = statistics.count

        guard items > 0 else { return MemberStatistic(avgFouls: 0, avgTwoPointAttempts: 0, avgThreePointAttempts: 0, avgPoints: 0) }

        let avgFouls = Double(statistics.map { $0.fouls }.reduce(0, +)) / Double(items)
        let avgTwoPointAttempts = Double(statistics.map { $0.twoPointAttempts }.reduce(0, +)) / Double(items)
        let avgThreePointAttempts = Double(statistics.map { $0.threePointAttempts }.reduce(0, +)) / Double(items)
        let avgPoints = Double(statistics.map { $0.points }.reduce(0, +)) / Double(items)

        return MemberStatistic(avgFouls: Int(avgFouls), avgTwoPointAttempts: Int(avgTwoPointAttempts), avgThreePointAttempts: Int(avgThreePointAttempts), avgPoints: Int(avgPoints))
    }
     
    func getPlayerStatistics(userAccountId: UUID, fetchLimit: Int = 7, terminType: String) throws -> [Statistic] {
        let predicate = #Predicate<Statistic> { $0.userAccountId == userAccountId && $0.terminType == terminType && $0.deletedAt == nil }
        
        var fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        fetchDescriptor.fetchLimit = fetchLimit
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func playerHasStatistic(userAccountId: UUID, terminId: UUID) throws -> Bool {
        let predicate = #Predicate<Statistic> { $0.userAccountId == userAccountId && $0.terminId == terminId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try container.mainContext.fetch(fetchDescriptor).first != nil
    }
    
    func getTeamRequests(teamId: UUID) throws -> [Requests] {
        let predicate = #Predicate<Requests> { $0.teamId == teamId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor<Requests>(predicate: predicate)
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func findRequest(teamId: UUID, userAccountId: UUID) throws -> [Requests] {
        let predicate = #Predicate<Requests> { $0.teamId == teamId && $0.accountId == userAccountId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor<Requests>(predicate: predicate)
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func getAttendance(userAccountId: UUID, terminId: UUID) throws -> Attendance? {
        let status = AttendanceStatus.confirmed.rawValue
        let predicate = #Predicate<Attendance> { $0.terminId == terminId && $0.userAccountId == userAccountId && $0.attendanceStatus == status && $0.deletedAt == nil }
        return try container.mainContext.fetch(FetchDescriptor(predicate: predicate)).first
    }
     
    func getTeamConfirmedAttendances(for terminId: UUID) throws -> [String] {
        let status = AttendanceStatus.confirmed.rawValue
        let predicate = #Predicate<Attendance> { $0.terminId == terminId && $0.attendanceStatus == status && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let attendances = try container.mainContext.fetch(fetchDescriptor)
        
        var userList: [String] = []
        
        for attendance in attendances {
            let userAccountId = attendance.userAccountId
            let predicate = #Predicate<UserAccount> { $0.id == userAccountId && $0.deletedAt == nil }
            
            if let userAccount: UserAccount = try container.mainContext.fetch(FetchDescriptor(predicate: predicate)).first {
                let userId = userAccount.userId
                let predicate = #Predicate<UserProfile> { $0.userId == userId && $0.deletedAt == nil }
                if let userProfile = try container.mainContext.fetch(FetchDescriptor(predicate: predicate)).first {
                    userList.append(userProfile.fullName)
                }
                
            }
        }
        return userList
    }
    
    func isTrainerAttendanceConfirmed(userAccountId: UUID, terminId: UUID) throws -> Bool {
        let predicate = #Predicate<Attendance> { $0.terminId == terminId && $0.userAccountId == userAccountId && $0.deletedAt == nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        let result = try container.mainContext.fetch(fetchDescriptor)
        return !result.isEmpty
    }
    
    func memberHasAttendance(userAccountId: UUID, terminId: UUID, confirmedOnly: Bool) -> Bool {
        do {
            let predicate: Predicate<Attendance>
            
            if confirmedOnly {
                let status = AttendanceStatus.confirmed.rawValue
                predicate = #Predicate<Attendance> { $0.terminId == terminId && $0.userAccountId == userAccountId && $0.attendanceStatus == status && $0.deletedAt == nil }
            } else {
                predicate = #Predicate<Attendance> { $0.terminId == terminId && $0.userAccountId == userAccountId && $0.deletedAt == nil }
            }
            
            let fetchDescriptor = FetchDescriptor(predicate: predicate)
            let result = try container.mainContext.fetch(fetchDescriptor)
            return !result.isEmpty
        } catch {
            return false
        }
    }
    
    func deleteLocalTeam(for team: Team) {
        container.mainContext.delete(team)
    }
    
    func softDelete(teamMember: TeamMember, userId: UUID) throws {
        teamMember.updatedAt = Date()
        teamMember.deletedAt = Date()
        try upsertLocal(item: teamMember, table: .teamMember, userId: userId)
        
        Task {
            try await SupabaseService.upsertWithOutResult(item: teamMember.toDTO(), table: .teamMember, onConflict: "id")
        }
    }
    
    func softDelete(teamAdmin: TeamAdmin, userId: UUID) throws {
        teamAdmin.updatedAt = Date()
        teamAdmin.deletedAt = Date()
        
        try upsertLocal(item: teamAdmin, table: .teamAdmin, userId: userId)
        
        Task {
            try await SupabaseService.upsertWithOutResult(item: teamAdmin.toDTO(), table: .teamAdmin, onConflict: "id")
        }
    }
    
    func softDelete(team: Team, userId: UUID) throws {
        team.updatedAt = Date()
        team.deletedAt = Date()
        
        try upsertLocal(item: team, table: .attendance, userId: userId)
        
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
    
    func requestTeam(request: Requests) async throws {
        try await SupabaseService.upsertWithOutResult(item: request.toDTO(), table: .request, onConflict: "id")
    }
    
    func upsertTerminAttendance(attendance: Attendance, userId: UUID) async throws {
        defer { upsertlocal(item: attendance, table: .attendance, userId: userId) }
        do {
            try await SupabaseService.upsertWithOutResult(item: attendance.toDTO(), table: .attendance, onConflict: "id")
        } catch {
            throw error
        }
    }
    
    func upsertPlayerStatistic(statistic: Statistic, userId: UUID) async throws {
        defer { upsertlocal(item: statistic, table: .statistic, userId: userId) }
        do {
            try await SupabaseService.upsertWithOutResult(item: statistic.toDTO(), table: .statistic, onConflict: "id")
        } catch {
            throw error
        }
    }
    
    // MARK: - REMOTE
    func getTeamRemote(code: String) async throws -> TeamDTO? {
        return try await SupabaseService.getEquals(value: code, table: .team, column: "joinCode")
    }
    
    func joinTeamWithCode(_ code: String, userAccount: UserAccount) async throws {
        if let foundTeamDTO = try await getTeamRemote(code: code) {
            // CREATE MEMBER
            let newMember = TeamMember(userAccountId: userAccount.id, teamId: foundTeamDTO.id, shirtNumber: nil, position: "", role: userAccount.role, createdAt: Date(), updatedAt: Date())
            // INSER MEMBER REMOTE
            print("before insert")
            let supabaseMember: TeamMemberDTO = try await SupabaseService.insert(item: newMember.toDTO(), table: .teamMember)
            print("after insert")
            // UPDATE LOCAL CURRENTUSERACCOUNT
            userAccount.teamId = newMember.teamId
            userAccount.updatedAt = Date()
            
            // INSERT LOCAL MEMBER
            try self.upsertLocal(item: foundTeamDTO.toModel(), table: .team, userId: userAccount.userId)
            try self.upsertLocal(item: supabaseMember.toModel(), table: .teamMember, userId: userAccount.userId)
       
            print("before upsert")
            try await SupabaseService.upsertWithOutResult(item: userAccount.toDTO(), table: .userAccount, onConflict: "id")
            print("after upsert")
        } else {
            throw TeamError.noTeamFoundwithThisJoinCode
        }
    }
    
    func insertTeam(newTeam: Team, userId: UUID) async throws {
        let entry: TeamDTO = try await SupabaseService.insert(item: newTeam.toDTO(), table: .team)
         
        try self.upsertLocal(item: entry.toModel(), table: .team, userId: userId)
    }
    
    func insertTeamMember(newMember: TeamMember, userId: UUID) async throws {
        let entry: TeamMemberDTO = try await SupabaseService.insert(item: newMember.toDTO(), table: .teamMember)
         
        try self.upsertLocal(item: entry.toModel(), table: .teamMember, userId: userId)
    }
    
    func upsertTeamMemberRemote(teamMember: TeamMember) async throws {
        try await SupabaseService.upsertWithOutResult(item: teamMember.toDTO(), table: .teamMember, onConflict: "id")
    }
    
    func upsertTeamRemote(team: Team) async throws {
        try await SupabaseService.upsertWithOutResult(item: team.toDTO(), table: .team, onConflict: "id")
    }
    
    // TODO: UMBAU ZU IGNORE UPSERT BEI KEIN INTERNET
    func insertTeamAdmin(newAdmin: TeamAdmin, userId: UUID) async throws {
        do {
            newAdmin.updatedAt = Date()
            try await SupabaseService.upsertWithOutResult(item: newAdmin.toDTO(), table: .teamAdmin, onConflict: "userAccountId")
            try self.upsertLocal(item: newAdmin, table: .teamAdmin, userId: userId)
        } catch {
            if ErrorIdentifier.isConnectionTimedOut(error: error) {
                try self.upsertLocal(item: newAdmin, table: .teamAdmin, userId: userId)
            }
        }
    }
    
    func searchTeamByName(name: String) async throws -> [TeamDTO] {
        return try await SupabaseService.search(name: name, table: DatabaseTable.team, column: "teamName")
    }
    
    func insertAbsense(absence: Absence, userId: UUID) async throws {
        try self.upsertLocal(item: absence, table: .absence, userId: userId)
        try await SupabaseService.upsertWithOutResult(item: absence.toDTO(), table: .absence, onConflict: "id")
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
    
    func getTrainersForTermineWhenIsConfirmed(terminId: UUID) throws -> [Attendance] {
        let status = AttendanceStatus.confirmed.rawValue
        let predicate = #Predicate<Attendance> { $0.terminId == terminId && $0.attendanceStatus == status && $0.deletedAt == nil && $0.trainerConfirmedAt != nil }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        return try container.mainContext.fetch(fetchDescriptor)
    }
}
