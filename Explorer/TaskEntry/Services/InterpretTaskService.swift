//
//  InterpretTaskViewModel.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import Foundation
import UIKit

protocol InterpretTaskService: ObservableObject {
    func interpretTask(prompt: String) async throws -> TaskModel
}

final class InterpretTaskServiceImpl: InterpretTaskService {
    private let service: OpenAIService
    
    init(service: OpenAIService) {
        self.service = service
    }
    
    func interpretTask(prompt: String) async throws -> TaskModel {
        // get the current date and time
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let dateString = formatter.string(from: currentDateTime)
        
        let prompts = ["From a user-inputted prompt, tell me the task that was inputted excluding any time or any location as a noun: " + prompt, "From a user-inputted prompt, output a single emoji that best describes the task described: " + prompt, "Suggest a date and time for the task in ISO 8601 format. Todays date is " + dateString + "and the task prompt is " + prompt, "Suggest a familiar location the task should be completed at in a location format: " + prompt]
            
        let completion = try await service.fetchCompletion(prompts: prompts)
        let task = completion[0]
        let emoji = completion[1]
        let date = completion[2]
        let location = completion[3]
        
        let interpretedTask = await TaskModel(device_uuid: UIDevice.current.identifierForVendor!.uuidString, task: task, location: location, time: date, emoji: emoji)
        return interpretedTask
    }
}
