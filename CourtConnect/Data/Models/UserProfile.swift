//
//  UserProfileResponse.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation
import SwiftData

@Model class UserProfile: Codable {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var firstName: String
    var lastName: String
    var birthday: Date
    var roleString: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case birthday
        case roleString
        case userId
        case createdAt
        case updatedAt
    }
    
    init(id: UUID = UUID(), userId: UUID = UUID(), firstName: String, lastName: String, birthday: Date, roleString: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.roleString = roleString
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.roleString = try container.decode(String.self, forKey: .roleString)
          
        let bithdayString = try container.decode(String.self, forKey: .birthday)
        self.birthday = DateUtil.convertDateStringToDate(string: bithdayString) ?? Date()
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        self.createdAt = DateUtil.convertDateStringToDate(string: createdAtString) ?? Date()
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        self.updatedAt = DateUtil.convertDateStringToDate(string: updatedAtString) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(roleString, forKey: .roleString)
        
        let birthdayString = DateUtil.convertDateToString(date: birthday)
        try container.encode(birthdayString, forKey: .birthday)
        
        let createdAtString = DateUtil.convertDateToString(date: createdAt)
        try container.encode(createdAtString, forKey: .createdAt)
        
        let updatedAtString = DateUtil.convertDateToString(date: updatedAt)
        try container.encode(updatedAtString, forKey: .updatedAt)
    }
} 

extension UserProfile {
    var role: UserRole? {
        UserRole(rawValue: self.roleString)
    }
}
