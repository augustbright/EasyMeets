//
//  UpcomingEventsView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 11.01.2023.
//

import SwiftUI
import Firebase
import os

struct UpcomingEventsView: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var events: [EventModel]?
    
    private let logger = Logger()
    
    var body: some View {
        WithUser {
            Text("Sign in to see you upcoming events")
        } content: { user, _ in
            VStack {
                if let events {
                    ForEach(events) { event in
                        NavigationLink {
                            EventPage(eventId: event.id!)
                        } label: {
                            EventPreviewSmall(eventPreview: event)
                        }
                    }

                    if events.count == 0 {
                        Text("You are not participating in any events")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear() { fetchUpcomingEvents(userId: user.uid) }
        }
    }
    
    func fetchUpcomingEvents(userId: String) {
        logger.log("fetching upcoming events")

        let db = Firestore.firestore()
        let collection = db.collection("Events").whereField("peopleAttending", arrayContains: userId)
        collection.addSnapshotListener {
            snapshot, error in
            guard error == nil else { return }
            guard let snapshot else { return }
            
            self.events = snapshot.documents.map() {
                document in EventModel(data: document.data(), id: document.documentID)
            }
        }
    }
}

struct UpcomingEventsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                UpcomingEventsView()
            }
        }
        .environmentObject(UserManager())
    }
}
