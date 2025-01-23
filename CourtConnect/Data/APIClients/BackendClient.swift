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
        supabaseURL: URL(string: TokenService.shared.supabaseHost)!,
        supabaseKey: TokenService.shared.supabasekey
    )
}
