//
//  CreateEventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct CreateEventPage: View {
    @State private var title = ""
    @State private var description = ""
    var body: some View {
        VStack {
            Text("Create a new event...").font(.title)
                TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
                TextEditor(text: $description)
            
            Button("Submit") {
                
            }
        }
        .padding(.horizontal)
    }
}

struct CreateEventPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventPage()
    }
}
