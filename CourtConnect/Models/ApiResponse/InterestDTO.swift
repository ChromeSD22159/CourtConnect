//
//  InterestDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

struct InterestDTO: DTOProtocol {
    var id: UUID
    var memberId: UUID
    var terminId: UUID
    var willParticipate: Bool
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, memberId: UUID, terminId: UUID, willParticipate: Bool, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.memberId = memberId
        self.terminId = terminId
        self.willParticipate = willParticipate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Interest {
        return Interest(id: id, memberId: memberId, terminId: terminId, willParticipate: willParticipate, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
