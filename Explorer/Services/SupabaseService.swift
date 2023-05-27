//
//  SupabaseService.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import Foundation
import Supabase
import UIKit

protocol SupabaseService {
    func fetchTasks() async -> [TaskModel]
}

final class SupabaseServiceImpl: SupabaseService {
    private let supabaseClient: SupabaseClient
    
    init() {
        supabaseClient = SupabaseClient(supabaseURL: URL(string: "https://hfaepibfavxjgenhhabc.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmYWVwaWJmYXZ4amdlbmhoYWJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODUwNjQ5ODIsImV4cCI6MjAwMDY0MDk4Mn0.umnbgZl5rEkvWc6cLDzu5Ibh0I5AtksFif80v1UefL0")
    }
    
    func fetchTasks() async -> [TaskModel] {
        let query = await supabaseClient.database
                    .from("Tasks")
                    .select() // keep it empty for all, else specify returned data
                    .eq(column: "device_uuid", value: UIDevice.current.identifierForVendor!.uuidString)
                    .order(column: "time")
                    
        do {
            let response: [TaskModel] = try await query.execute().value
            return response
        } catch {
            print("### Insert Error: \(error)")
            return []
        }
    }
    
    func insertTask(task: TaskModel) async {
        let query = supabaseClient.database
                    .from("Tasks")
                    .insert(values: task,
                            returning: .representation) // you will need to add this to return the added data
                    .select(columns: "id") // specifiy which column names to be returned. Leave it empty for all columns
                    .single() // specify you want to return a single value.
        
        do {
            try await query.execute().value
        } catch {
            print("### Insert Error: \(error)")
        }
    }
}
