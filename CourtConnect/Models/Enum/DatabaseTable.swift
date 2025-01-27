//
//  DatabaseTable.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import SwiftData

enum DatabaseTable: String, CaseIterable {
    
    case userProfile = "UserProfile"
    case userOnline = "UserOnline"
    case messages = "Messages"
    case userAccount = "UserAccount"
    case team = "Team"
    case deletionRequest = "DeletionRequest"
    case updateHistory = "UpdateHistory"
    
    var remoteModel: any DTOProtocol.Type {
        switch self {
        case .userProfile: return UserProfileDTO.self
        case .userOnline: return UserAccountDTO.self
        case .messages: return ChatDTO.self
        case .userAccount: return UserAccountDTO.self
        case .team: return TeamDTO.self
        case .deletionRequest: return TeamDTO.self
        case .updateHistory: return TeamDTO.self
        }
    }
    
    var localModel: any ModelProtocol.Type {
        switch self {
        case .userProfile: return UserProfile.self
        case .userOnline: return UserAccount.self
        case .messages: return Chat.self
        case .userAccount: return UserAccount.self
        case .team: return Team.self
        case .deletionRequest: return Team.self
        case .updateHistory: return Team.self
        }
    }
}
