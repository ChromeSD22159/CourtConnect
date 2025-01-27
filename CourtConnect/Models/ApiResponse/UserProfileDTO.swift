//
//  UserProfileDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

class UserProfileDTO: DTOProtocol { 
    var id: UUID
    var userId: UUID
    var firstName: String
    var lastName: String
    var birthday: String
    var fcmToken: String?
    var lastOnline: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
     
    init(id: UUID = UUID(), userId: UUID, fcmToken: String? = nil, firstName: String, lastName: String, birthday: String, lastOnline: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.fcmToken = fcmToken
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.lastOnline = lastOnline
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> UserProfile {
        UserProfile(id: id, userId: userId, firstName: firstName, lastName: lastName, birthday: birthday, lastOnline: lastOnline, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
