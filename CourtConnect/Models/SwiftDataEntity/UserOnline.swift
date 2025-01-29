//
//  UserOnline.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftData
import Foundation

@Model
class UserOnline: ModelProtocol {
    var id: UUID
    var userId: UUID
    var firstName: String
    var lastName: String
    var deviceToken: String
    var timestamp: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, firstName: String, lastName: String, deviceToken: String, timestamp: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.timestamp = timestamp
        self.deviceToken = deviceToken
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> UserOnlineDTO {
        return UserOnlineDTO(id: id, userId: userId, firstName: firstName, lastName: lastName, deviceToken: deviceToken)
    }
}
