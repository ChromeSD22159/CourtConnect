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
        var currentRegion: MKCoordinateRegion? // Zwischenspeicher für die Region
        var geocodingCompleted = false
        let geocoder = CLGeocoder()
        geocodingCompleted = false // Flag zurücksetzen

        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Geocoding Fehler: \(error.localizedDescription)")
                geocodingCompleted = true // Flag setzen, auch im Fehlerfall
                return
            }

            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Adresse nicht gefunden")
                geocodingCompleted = true // Flag setzen
                return
            }

            let coordinate = location.coordinate
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            currentRegion = region // Region im Zwischenspeicher speichern
            geocodingCompleted = true // Flag setzen
        }
 
        while !geocodingCompleted {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1)) // Kurze Pause
        }

        let region = currentRegion // Wert aus dem Zwischenspeicher zurückgeben
        currentRegion = nil // Zwischenspeicher zurücksetzen
        return region
    }
}
