//
//  UserProfileResponse.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Foundation
import SwiftData 

@Model
class UserProfile: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var firstName: String
    var lastName: String
    var birthday: String
    var fcmToken: String?
    var imageURL: String?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var lastOnline: Date
    var onBoardingAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, fcmToken: String? = nil, firstName: String, lastName: String, birthday: String, lastOnline: Date = Date(), imageURL: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil, onBoardingAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.fcmToken = fcmToken
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.lastOnline = lastOnline
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.onBoardingAt = onBoardingAt
    }
    
    func toDTO() -> UserProfileDTO {
        UserProfileDTO(id: id, userId: userId, fcmToken: fcmToken, firstName: firstName, lastName: lastName, birthday: birthday, lastOnline: lastOnline, imageURL: imageURL, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt, onBoardingAt: onBoardingAt)
    }
}
  
extension UserProfile {
    func toUserOnline() -> UserOnlineDTO {
        return UserOnlineDTO(userId: userId, firstName: firstName, lastName: lastName, deviceToken: "asds")
    }
    
    var fullName: String {
        return firstName + " " + lastName
    }
    
    var inizials: String {
        guard let first = firstName.first, let second = lastName.first else { return "" }
        
        return "\(first)\(second)"
    }
}
