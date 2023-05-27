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
    @State private var tasks: [TaskModel] = []
    
    @State private var prompt: String = ""
    @State private var secretKey: String = " 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"
    @State private var openAIClient: Client

    @State private var UUID: String = UIDevice.current.identifierForVendor!.uuidString
    
    init() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))


        let configuration = Configuration(apiKey: " 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", organization: "org-QqYksxfIJk7bzRPd68UsBvkj")

        openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
    }

    var body: some View {
        VStack {
            TaskListScreen()
            Text("Let's explore!")
            HStack {
                TextField("Give me something", text: $prompt)
                Button {
                    Task {
                        do {
                            // get the current date and time
                            let currentDateTime = Date()

                            // initialize the date formatter and set the style
                            let formatter = DateFormatter()
                            formatter.timeStyle = .medium
                            formatter.dateStyle = .long
                            let dateString = formatter.string(from: currentDateTime)
                            
                            let completion = try await openAIClient.completions.create(
                                model: Model.GPT3.textDavinci003,
                                prompts: ["From a user-inputted prompt, tell me the task that was inputted excluding any time or any location as a noun: " + prompt, "From a user-inputted prompt, output a single emoji that best describes the task described: " + prompt, "Suggest a date and time for the task in ISO 8601 format. Todays date is " + dateString + "and the task prompt is " + prompt, "Suggest a familiar location the task should be completed at in a location format: " + prompt]
                            )
                            
                            let garbageCharacters = CharacterSet(charactersIn: ". \n")
                            let task = completion.choices[0].text.trimmingCharacters(in: garbageCharacters)
                            let emoji = completion.choices[1].text.trimmingCharacters(in: garbageCharacters)
                            let date = completion.choices[2].text.trimmingCharacters(in: garbageCharacters)
                            let location = completion.choices[3].text.trimmingCharacters(in: garbageCharacters)

                            let insertData = TaskModel(device_uuid: UUID, task: task, location: location, time: date, emoji: emoji)
                            
                            prompt = ""
                            tasks.append(insertData)
                            
                            let query = supabaseClient.database
                                        .from("Tasks")
                                        .insert(values: insertData,
                                                returning: .representation) // you will need to add this to return the added data
                                        .select(columns: "id") // specifiy which column names to be returned. Leave it empty for all columns
                                        .single() // specify you want to return a single value.
                            Task {
                                do {
                                    let response: [TaskModel] = try await query.execute().value
                                    print("### Returned: \(response)")
                                } catch {
                                    print("### Insert Error: \(error)")
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Image(systemName: "plus.app.fill")
                }
            }
        }
        .padding()
    }
}
