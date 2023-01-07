//
//  ExploreEventsView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI
import Firebase

struct ExploreEventsView: View {
    @State private var searchText = ""
    @State private var filterFavorite = false
    @State private var events: [EventModel]?
        
    var body: some View {
        VStack {
            if let events = events {
                NavigationStack() {
                    List(events) { event in
                        NavigationLink  {
                            EventPage(eventId: event.id!)
                        } label: {
                            EventPreview(eventPreview: event)
                        }
                    }
                    .navigationTitle(filterFavorite ? "Events (saved)" : "Events")
                    .toolbar {
                        ToolbarItem {
                            FavoriteButton(isSet: $filterFavorite)
                        }
                    }
                    .searchable(text: $searchText)
                }
            }
        }
        .onAppear() {
            self.fetchEvents()
        }
    }

    func fetchEvents() {
        let db = Firestore.firestore()
        let collection = db.collection("Events")
        collection.addSnapshotListener() {
            (querySnapshot, error) in
            guard error == nil else {
                return
            }
            self.events = querySnapshot!.documents.map() {
                document in EventManager.eventFromData(document.data(), document.documentID)
            }
        }
    }
}

struct ExploreEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreEventsView()
    }
}
