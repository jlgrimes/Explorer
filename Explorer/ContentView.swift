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

struct ContentView: View {
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
                                prompts: ["From a user-inputted prompt, tell me the task that was inputted excluding any time or any location as a noun: " + prompt, "From a user-inputted prompt, output a single emoji that best describes the task described: " + prompt, "Suggest a date and time for the task without the time in ISO 8601 format. Todays date is " + dateString + "and the task prompt is " + prompt, "Suggest a familiar location the task should be completed at in a location format: " + prompt]
                            )
                            print(completion.choices[0].text)
                            print("===")
                            print(completion.choices[1].text)
                            print("===")
                            print(completion.choices[2].text)
                            print("===")
                            print(completion.choices[3].text)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
