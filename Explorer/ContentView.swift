//
//  ContentView.swift
//  Explorer
//
//  Created by Jared Grimes on 5/25/23.
//

import SwiftUI
import OpenAIKit
import AsyncHTTPClient
import NIO
import Supabase

struct ContentView: View {
    var body: some View {
        VStack {
            TaskListScreen()
            TaskEntryScreen()
        }
        .padding()
    }
}
