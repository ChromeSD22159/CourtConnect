//
//  ImageUploadError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
 
enum ImageUploadError: Error {
    case conversionFailed
    case uploadFailed(Error)
}
