//
//  EventsList.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.03.2023.
//

import SwiftUI

struct EventsList: View {
    var events: [EventModel]

    var body: some View {
        ForEach(events) { event in
            NavigationLink  {
                EventPage(eventId: event.id!)
            } label: {
                EventPreview(eventPreview: event)
            }
        }
        .buttonStyle(.plain)
    }
}

struct EventsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventsList(events: [EventModel.mock])
        }
    }
}
