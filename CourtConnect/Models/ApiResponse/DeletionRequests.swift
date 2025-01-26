//
//  DeletionRequests.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
//
import Foundation 

struct DeletionRequestDTO: Codable {
    var id: UUID
    var userId: UUID
    
    init(id: UUID = UUID(), userId: UUID) {
        self.id = id
        self.userId = userId
    }
}
