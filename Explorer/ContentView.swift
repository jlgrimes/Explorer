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

struct TaskModel: Encodable, Decodable, Hashable {
    let device_uuid: String?
    let task: String?
    let location: String?
    let time: String?
    let emoji: String?
}

func getRelativeDate(task: TaskModel) -> String {
    let newFormatter = ISO8601DateFormatter()
    newFormatter.timeZone = TimeZone.current
    
    let seconds = TimeZone.current.secondsFromGMT()
    let hours = seconds/3600
    let minutes = abs(seconds/60) % 60
    let tz = String(format: "%+.2d:%.2d", hours, minutes)
    
    let timeString = task.time! + tz
    
    let date = newFormatter.date(from: timeString)

    let formatter = RelativeDateTimeFormatter()
    // get exampleDate relative to the current date
    let relativeDate = formatter.localizedString(for: date!, relativeTo: Date.now)
    
    return relativeDate
}

struct ContentView: View {
    @State private var tasks: [TaskModel] = []
    
    @State private var prompt: String = ""
    @State private var secretKey: String = " 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"
    @State private var openAIClient: Client
    @State private var supabaseClient: SupabaseClient
    
    @State private var UUID: String = UIDevice.current.identifierForVendor!.uuidString
    
    init() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))


        let configuration = Configuration(apiKey: " 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", organization: "org-QqYksxfIJk7bzRPd68UsBvkj")

        openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
        
        supabaseClient = SupabaseClient(supabaseURL: URL(string: "https://hfaepibfavxjgenhhabc.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmYWVwaWJmYXZ4amdlbmhoYWJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODUwNjQ5ODIsImV4cCI6MjAwMDY0MDk4Mn0.umnbgZl5rEkvWc6cLDzu5Ibh0I5AtksFif80v1UefL0")
    }
    
    private func fetchTasks() {
        let query = supabaseClient.database
                    .from("Tasks")
                    .select() // keep it empty for all, else specify returned data
                    .eq(column: "device_uuid", value: UUID)
                    
        Task {
            do {
                let response: [TaskModel] = try await query.execute().value
                tasks = response;
                print("### Returned: \(response)")
            } catch {
                print("### Insert Error: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                ForEach(tasks, id: \.self) { task in
                    let relativeDate = getRelativeDate(task: task)

                    HStack {
                        HStack {
                            Text(task.emoji!)
                            Text(task.task!)
                        }
                        Spacer()
                        Text(relativeDate)
                    }
                }
            }.padding()
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
                            let task = completion.choices[0].text.trimmingCharacters(in: .whitespacesAndNewlines)
                            let emoji = completion.choices[1].text.trimmingCharacters(in: .whitespacesAndNewlines)
                            let date = completion.choices[2].text.trimmingCharacters(in: .whitespacesAndNewlines)
                            let location = completion.choices[3].text.trimmingCharacters(in: .whitespacesAndNewlines)

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
        .onAppear {
            fetchTasks()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
