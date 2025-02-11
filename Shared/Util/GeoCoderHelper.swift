//
//  GeoCoderHelper.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 06.02.25.
//
import CoreLocation
import MapKit

struct GeoCoderHelper {
    static func getAddress(address: String) -> MKCoordinateRegion? {
        var currentRegion: MKCoordinateRegion?
        var geocodingCompleted = false
        let geocoder = CLGeocoder()
        geocodingCompleted = false

        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Geocoding Fehler: \(error.localizedDescription)")
                geocodingCompleted = true
                return
            }

            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Adresse nicht gefunden")
                geocodingCompleted = true
                return
            }

            let coordinate = location.coordinate
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            currentRegion = region
            geocodingCompleted = true
        }
 
        while !geocodingCompleted {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }

        let region = currentRegion
        currentRegion = nil
        return region
    }
    
    static func getCoordinates(address: String) async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let location = placemarks?.first?.location else {
                    continuation.resume(throwing: NSError(domain: "GeoCoderHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Adresse nicht gefunden"]))
                    return
                }
                
                continuation.resume(returning: location.coordinate)
            }
        }
    }
}
