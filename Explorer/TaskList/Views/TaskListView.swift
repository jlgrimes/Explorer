//
//  TaskListView.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import SwiftUI

struct TaskListView: View {
    let tasks: [TaskModel]
    
    var body: some View {
        VStack {
            ForEach(tasks, id: \.self) { task in
               TaskView(task: task)
            }
        }.padding()
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(tasks: [MockTaskModel])
    }
}
