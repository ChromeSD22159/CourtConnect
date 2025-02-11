//
//  TerminSheetViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import Foundation
import SwiftUI
import MapKit

@Observable @MainActor class TerminSheetViewModel {
    private let repository: BaseRepository
    var scrollPosition: ScrollPosition
    var position: MapCameraPosition
    var terminData: TerminSheetData
    private let terminId: UUID
    
    init(terminId: UUID) {
        self.terminId = terminId
        self.repository = Repository.shared
        self.scrollPosition = ScrollPosition()
        
        self.position  = MapCameraPosition.region(
            GeoCoderHelper.getAddress(address: "Greutwiesenstraße 17, 79787 Lauchringen")!
        )
        
        self.terminData = TerminSheetData(termin: MockTermine.termine.first!, confirmdUser: [])
        
        self.getTermin()
    }
    
    func getTermin() {
        do {
            if let termin = try repository.teamRepository.getTermineBy(id: terminId) {
                self.terminData.termin = termin
                
                self.position  = MapCameraPosition.region(
                    GeoCoderHelper.getAddress(address: termin.place) ?? GeoCoderHelper.getAddress(address: "Greutwiesenstraße 17, 79787 Lauchringen")!
                )
                 
                self.terminData.confirmdUser = try repository.teamRepository.getTeamConfirmedAttendances(for: termin.id)
            }
        } catch {
            print(error)
        }
    }
}
