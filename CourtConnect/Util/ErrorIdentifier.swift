//
//  ErrorIdentifier.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import Foundation

enum ErrorIdentifier {
    static func isInternetLost(error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNetworkConnectionLost
    }
 
    static func isConnectionTimedOut(error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut
    } 
}
