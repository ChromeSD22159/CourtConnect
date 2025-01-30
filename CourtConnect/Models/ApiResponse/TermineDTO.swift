//
//  TermineDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct TermineDTO: DTOProtocol {
    var id: UUID
    var locationId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), locationId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.locationId = locationId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> some ModelProtocol {
        return Termine(id: id, locationId: locationId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
