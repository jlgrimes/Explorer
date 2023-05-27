//
//  PromptInputView.swift
//  Explorer
//
//  Created by Jared Grimes on 5/26/23.
//

import SwiftUI

struct PromptInputView: View {
    @Binding var prompt: String
    
    var body: some View {
        TextField("Give me something", text: $prompt)
    }
}

//struct PromptInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        PromptInputView(prompt: "")
//    }
//}
