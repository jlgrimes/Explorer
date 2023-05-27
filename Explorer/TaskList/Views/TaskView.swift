//
//  TaskView.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import SwiftUI

func getRelativeDate(task: TaskModel) -> String {
    let newFormatter = ISO8601DateFormatter()
    newFormatter.timeZone = TimeZone.current
    
    let seconds = TimeZone.current.secondsFromGMT()
    let hours = seconds/3600
    let minutes = abs(seconds/60) % 60
    let tz = String(format: "%+.2d:%.2d", hours, minutes)
    
    let timeString = task.time! + tz
    
    let date = newFormatter.date(from: timeString)
    
    if (date == nil) {
        return "nil"
    }

    let formatter = RelativeDateTimeFormatter()
    // get exampleDate relative to the current date
    let relativeDate = formatter.localizedString(for: date!, relativeTo: Date.now)
    
    return relativeDate
}

struct TaskView: View {
    let task: TaskModel
    

    var body: some View {
        HStack {
            HStack {
                Text(task.emoji!)
                Text(task.task!)
            }
            Spacer()
            Text(getRelativeDate(task: task))
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: MockTaskModel)
    }
}
