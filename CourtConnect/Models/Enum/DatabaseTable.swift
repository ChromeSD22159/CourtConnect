//
//  DatabaseTable.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import SwiftData
import Supabase
import Foundation

enum DatabaseTable: String, CaseIterable {
    
    case attendance = "Attendance"
    case chat = "Chat"
    case deletionRequest = "DeletionRequest"
    case document = "Document"
    case interest = "Interest"
    case location = "Location"
    case request = "Request"
    case statistic = "Statistic"
    case team = "Team"
    case teamAdmin = "TeamAdmin"
    case teamMember = "TeamMember"
    case termine = "Termine"
    case updateHistory = "UpdateHistory"
    case userAccount = "UserAccount"
    case userOnline = "UserOnline"
    case userProfile = "UserProfile"
    
    static var tablesToSync: [DatabaseTable] {
        var tables = DatabaseTable.allCases
        tables.removeAll { $0 == .updateHistory || $0 == .userOnline }
        return tables
    }
    
    var remoteModel: any DTOProtocol.Type {
        switch self {
        case .document: return DocumentDTO.self
        case .interest: return InterestDTO.self
        case .location: return LocationDTO.self
        case .request: return RequestsDTO.self
        case .statistic: return StatisticDTO.self
        case .teamAdmin: return TeamAdminDTO.self
        case .teamMember: return TeamMemberDTO.self
        case .termine: return TermineDTO.self
        case .attendance: return AttendanceDTO.self
        case .userProfile: return UserProfileDTO.self
        case .userOnline: return UserOnlineDTO.self
        case .chat: return ChatDTO.self
        case .userAccount: return UserAccountDTO.self
        case .team: return TeamDTO.self
        case .deletionRequest: return TeamDTO.self
        case .updateHistory: return TeamDTO.self
        }
    }
    
    var whereStatement: String? {
        switch self {
        case .document: return "teamId"
        case .interest: return "teamId"
        case .location: return nil
        case .request: return "teamId"
        case .statistic: return "userId"
        case .teamAdmin: return "teamId"
        case .teamMember: return "teamId"
        case .termine: return "teamId"
        case .attendance: return "trainerId"
        case .userProfile: return "userId"
        case .userOnline: return nil
        case .chat: return "senderId, recipientId"
        case .userAccount: return "userId"
        case .team: return "id"
        case .deletionRequest: return nil
        case .updateHistory: return nil
        }
    }
    
    var localModel: any ModelProtocol.Type {
        switch self {
        case .document: return Document.self
        case .interest: return Interest.self
        case .location: return Location.self
        case .request: return Requests.self
        case .statistic: return Statistic.self
        case .teamAdmin: return TeamAdmin.self
        case .teamMember: return TeamMember.self
        case .termine: return Termine.self
        case .attendance: return Attendance.self
        case .userProfile: return UserProfile.self
        case .userOnline: return UserOnline.self
        case .chat: return Chat.self
        case .userAccount: return UserAccount.self
        case .team: return Team.self
        case .deletionRequest: return Team.self
        case .updateHistory: return Team.self
        }
    }
    
    var onConflict: String {
        switch self {
        case .document: return "id"
        case .interest: return "id"
        case .location: return "id"
        case .request: return "id"
        case .statistic: return "id"
        case .teamAdmin: return "id"
        case .teamMember: return "id"
        case .termine: return "id"
        case .attendance: return "id"
        case .userProfile: return "id"
        case .userOnline: return "id"
        case .chat: return "id"
        case .userAccount: return "id"
        case .team: return "id"
        case .deletionRequest: return "id"
        case .updateHistory: return "id"
        }
    }
}
 
struct DatabaseTableWhereValues {
    var teamId: UUID
    var userId: UUID
    var trainerId: UUID
}
