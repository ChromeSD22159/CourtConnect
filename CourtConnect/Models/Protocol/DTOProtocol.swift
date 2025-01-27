//
//  DTOProtocol.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
// 
import Foundation
   
protocol DTOProtocol: SupabaseEntitiy, Codable, Decodable, Encodable {
    associatedtype Model: ModelProtocol
    func toModel() -> Model
}
