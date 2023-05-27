//
//  TaskListScreen.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import SwiftUI

struct TaskListScreen: View {
    @StateObject private var vm = TasksViewModelImpl(service: SupabaseServiceImpl())
    
    var body: some View {
        TaskListView(tasks: vm.tasks).task {
            await vm.getTasks()
        }
    }
}

struct TaskListScreen_Previews: PreviewProvider {
    static var previews: some View {
        TaskListScreen()
    }
}
