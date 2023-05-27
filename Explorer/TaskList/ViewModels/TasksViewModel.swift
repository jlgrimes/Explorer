//
//  TasksViewModel.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import Foundation

protocol TasksViewModel: ObservableObject {
    func getTasks() async
}

@MainActor
final class TasksViewModelImpl: TasksViewModel {
    @Published private(set) var tasks: [TaskModel] = []
    
    private let service: SupabaseService
    
    init(service: SupabaseService) {
        self.service = service
    }
    
    func getTasks() async {
        self.tasks = await service.fetchTasks()
    }
}
