//
//  Location.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import SwiftData
import Foundation

@Model
class Location: ModelProtocol {
    @Attribute(.unique) var id: UUID
    var name: String
    var street: String
    var number: String
    var zip: String
    var city: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, name: String, street: String, number: String, zip: String, city: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.street = street
        self.number = number
        self.zip = zip
        self.city = city
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toDTO() -> LocationDTO {
        return LocationDTO(id: id, name: name, street: street, number: number, zip: zip, city: city, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
