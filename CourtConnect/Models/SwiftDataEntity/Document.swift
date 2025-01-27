//
//  Document.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation
import SwiftData

@Model class Document: ModelProtocol {
    var id: UUID
    var teamId: UUID
    var name: String
    var info: String
    var url: String
    var roleString: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamId: UUID, name: String, info: String, url: String, roleString: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.name = name
        self.info = info
        self.url = url
        self.roleString = roleString
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> DocumentDTO {
        DocumentDTO(id: id, teamId: teamId, name: name, info: info, url: url, roleString: roleString, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
