//
//  TaskEntryScreen.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import SwiftUI

struct TaskEntryScreen: View {
    @State private var prompt = ""
    private var interpretService = InterpretTaskServiceImpl(service: OpenAIServiceImpl())
    private var supabaseService = SupabaseServiceImpl()
    
    var body: some View {
        HStack {
            PromptInputView(prompt: $prompt)
            Button {
                Task {
                    do {
                        let interpretedTask = try await interpretService.interpretTask(prompt: prompt)
                        await supabaseService.insertTask(task: interpretedTask)
                    } catch {
                        print(error)
                    }
                    prompt = ""
                }
            } label: {
                Image(systemName: "plus.app.fill")
            }
        }
    }
}

struct TaskEntryScreen_Previews: PreviewProvider {
    static var previews: some View {
        TaskEntryScreen()
    }
}
