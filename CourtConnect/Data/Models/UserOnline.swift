//
//  UserOnline.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import SwiftData
import Foundation
import UIKit

class UserOnline: Identifiable, Codable {
    var id: UUID
    var userId: String
    var deviceToken: String
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id, userId, deviceToken, timestamp
    }
    
    init(id: UUID = UUID(), userId: String, deviceToken: String, timestamp: Date = Date()) {
        self.id = id
        self.userId = userId
        self.timestamp = timestamp
        self.deviceToken = deviceToken
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.deviceToken = try container.decode(String.self, forKey: .deviceToken)
        
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        self.timestamp = DateUtil.convertDateStringToDate(string: timestampString) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(deviceToken, forKey: .deviceToken)
        
        let timestampString = DateUtil.convertDateToString(date: timestamp)
        try container.encode(timestampString, forKey: .timestamp)
    }
}
