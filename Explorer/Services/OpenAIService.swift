//
//  OpenAIService.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import Foundation
import OpenAIKit
import AsyncHTTPClient
import NIO
import UIKit

protocol OpenAIService {
    func fetchCompletion(prompts: [String]) async throws -> [String]
}

final class OpenAIServiceImpl: OpenAIService {
    private let openAIClient: Client
    
    init() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))


        let configuration = Configuration(apiKey: " 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", organization: "org-QqYksxfIJk7bzRPd68UsBvkj")

        self.openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
    }
    
    func fetchCompletion(prompts: [String]) async throws -> [String] {
        let completion = try await openAIClient.completions.create(
            model: Model.GPT3.textDavinci003,
            prompts: prompts
        )
        
        let garbageCharacters = CharacterSet(charactersIn: ". \n")
        return completion.choices.map { $0.text.trimmingCharacters(in: garbageCharacters)}
    }
}
