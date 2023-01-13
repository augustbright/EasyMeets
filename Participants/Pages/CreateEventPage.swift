//
//  CreateEventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct CreateEventPage: View {
    @State private var event: EventModel?
    var body: some View {
        VStack {
            if let event {
                EventView(event: event)
            } else {
                NewEventView(event: $event)
            }
        }
    }
}

struct CreateEventPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateEventPage()
                .environmentObject(UserManager())
        }
    }
}
