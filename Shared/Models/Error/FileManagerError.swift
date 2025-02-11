//
//  FileManagerError.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import Foundation

enum FileManagerError: Error, LocalizedError {
    case canNotReadImage, canNotReadPdf
    case canNotSaveImage, canNotSavePdf
}
