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
    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    var locations: [ExampleLocation] = []
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
                
                self.generateMarker(adress: termin.place)
            }
        } catch {
            print(error)
        }
    }
    
    func generateMarker(adress: String) {
        Task {
            do {
                let annotation = try await GeoCoderHelper.getCoordinates(address: adress)
                
                locations.append(ExampleLocation(name: "Location", latitude: annotation.latitude, longitude: annotation.longitude))
                
                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
            }
        }
    }
}

struct ExampleLocation: Identifiable {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
