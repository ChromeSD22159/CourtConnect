//
//  APNsJWTManager.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.01.25.
//
import SwiftJWT
import CryptoKit
import Foundation
 
struct ApnsMessaging {
    static var shared = ApnsMessaging()
    
    var apnsToken: String?
    
    static func sendAPNsNotification(deviceToken: String, title: String, body: String, completion: @escaping (Result<Bool?, ApnsError>) -> Void) throws {
        guard let url = URL(string: "https://api.sandbox.push.apple.com/3/device/\(deviceToken)") else {
            completion(Result.failure(ApnsError.invalidDeviceToken))
            return
        }
        
        let authToken = try generateJWT(keyId: "3297Y8FD2Z", teamId: "ZD275Y62U7")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("de.frederikkohler.CourtConnect", forHTTPHeaderField: "apns-topic")

        let alert = Alert(title: title, body: body)
        let aps = Aps(alert: alert, sound: "default")
        let payload = Payload(aps: aps)

        request.httpBody = try JSONEncoder().encode(payload)

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if (error != nil) {
                completion(Result.failure(ApnsError.badRequest))
              return
            }
            
            completion(Result.success(response?.isRequestSuccessful()))
        }

        task.resume()
    }
    
    static func generateJWT(keyId: String, teamId: String) throws -> String {
        
        // Den privaten Schlüssel als Data laden
        let privateKeyData = Data(TokenService.pemBasedPrivateKey.utf8)
        
        // Claims für das JWT definieren (aus den Parametern: teamId und aktuellem Datum)
        let claims = APNsJWTClaims(iss: teamId, iat: Date())

        // Header erstellen (mit dem `kid`, also dem Key Identifier)
        let header = Header(kid: keyId)

        // JWT-Signer mit dem privaten Schlüssel erstellen (ES256)
        let jwtSigner = JWTSigner.es256(privateKey: privateKeyData)

        // JWT erstellen und signieren
        var jwt = JWT(header: header, claims: claims)
        let signedJWT = try jwt.sign(using: jwtSigner)
        
        return signedJWT
    }
    
    private struct Payload: Codable {
        var aps: Aps
    }
    
    private struct Aps: Codable {
        var alert: Alert
        var sound: String
    }
    
    private struct Alert: Codable {
        var title: String
        var body: String
    }
    
    private struct APNsJWTClaims: Claims {
        let iss: String
        let iat: Date
    } 
    
    /// curl -v -X POST \
    /// https://api.sandbox.push.apple.com/3/device/<Device> \
    /// -H "Authorization: Bearer <JWT>" \
    /// -H "Content-Type: application/json" \
    /// -H "apns-topic: de.frederikkohler.CourtConnect" \
    /// -d '{
    ///   "aps": {
    ///     "alert": {
    ///       "title": "Test Notification",
    ///       "body": "Dies ist eine Testnachricht"
    ///     },
    ///     "sound": "default"
    ///   }
    /// }'
    ///
    
    enum ApnsError: Error, LocalizedError {
        case invalidDeviceToken, badRequest
    }
}
