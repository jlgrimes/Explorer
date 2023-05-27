//
//  TaskModel.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import Foundation

struct TaskModel: Encodable, Decodable, Hashable {
    let device_uuid: String?
    let task: String?
    let location: String?
    let time: String?
    let emoji: String?
}

let MockTaskModel = TaskModel(device_uuid: "mock-uuid", task: "Take out the trash", location: "Home", time: "2023-05-25T23:31:04", emoji: "🗑️")
