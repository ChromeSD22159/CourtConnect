//
//  BackendClient.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 12.01.25.
//
import Supabase
import Foundation

struct BackendClient {
    static var shared = BackendClient()
    
    let supabase = SupabaseClient(
      supabaseURL: URL(string: "https://anwqiuyfuhaebycbblrc.supabase.co")!,
      supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFud3FpdXlmdWhhZWJ5Y2JibHJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY2MzY0MTcsImV4cCI6MjA1MjIxMjQxN30.JBCicVin0f56ZLj8BL7YEIMIETVxOF0I_dfbyMtx-R4"
    )
}
