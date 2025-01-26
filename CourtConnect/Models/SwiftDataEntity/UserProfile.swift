//
//  UserProfileResponse.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation
import SwiftData

@Model
class UserProfile: Codable {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var firstName: String
    var lastName: String
    var birthday: String
    var fcmToken: String?
    var createdAt: Date
    var updatedAt: Date
    var lastOnline: Date
    
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, birthday, userId, fcmToken, updatedAt, lastOnline
        case createdAt = "created_at"
    }
    
    init(id: UUID = UUID(), userId: UUID, fcmToken: String? = nil, firstName: String, lastName: String, birthday: String, createdAt: Date = Date(), updatedAt: Date = Date(), lastOnline: Date = Date()) {
        self.id = id
        self.userId = userId
        self.fcmToken = fcmToken
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastOnline = lastOnline
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        self.fcmToken = try container.decode(String?.self, forKey: .fcmToken)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.birthday = try container.decode(String.self, forKey: .birthday)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.lastOnline = try container.decode(Date.self, forKey: .lastOnline)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(fcmToken, forKey: .fcmToken)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(birthday, forKey: .birthday)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(updatedAt, forKey: .lastOnline)
    }
} 

extension UserProfile { 
    
    func toUserOnline() -> UserOnline {
        return UserOnline(userId: userId, firstName: firstName, lastName: lastName, deviceToken: "asds")
    }
    
    var fullName: String {
        return firstName + " " + lastName
    }
    
    var inizials: String {
        guard let first = firstName.first, let second = lastName.first else { return "" }
        
        return "\(first)\(second)"
    }
}
