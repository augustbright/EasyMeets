//
//  EventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct EventPage: View {
    var eventId: String

    @State private var error: Error?
    @State private var event: EventModel?

    var body: some View {
        VStack {
            if let event {
                EventView(event: event)
            }
        }
        .onAppear{ fetchEvent(eventId) }
    }
    
    func fetchEvent(_ eventId: String) {
        let db = Firestore.firestore()
        let eventRef = db.collection("Events").document(eventId)
        eventRef.addSnapshotListener() {
            (document, error) in
            guard error == nil else {
                self.error = error
                return
            }
            if let document, document.exists, let data = document.data() {
                self.event = EventModel(data: data, id: document.documentID)
            }
        }
    }
    
}

struct EventPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventPage(eventId: "S2bZIbKEk8NR13Ds9Nut")
                .environmentObject(UserManager())
        }
    }
}
