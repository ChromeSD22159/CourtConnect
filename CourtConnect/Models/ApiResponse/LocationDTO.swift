//
//  LocationDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct LocationDTO: DTOProtocol {
    var id: UUID
    var name: String
    var street: String
    var number: String
    var zip: String
    var city: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    func toModel() -> Location {
        return Location(id: id, name: name, street: street, number: number, zip: zip, city: city, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}


