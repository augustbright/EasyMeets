//
//  ExploreEventsPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 09.01.2023.
//

import SwiftUI
import Firebase

struct ExploreEventsPage: View {
    @State private var searchText = ""
    @State private var filterFavorite = false
    @State private var events: [EventModel]?
    @State private var error: Error?
    
    var body: some View {
        VStack {
            if let error {
                Text(error.localizedDescription)
            }
            if let events = events {
                List(events) { event in
                    Section {
                        NavigationLink  {
                            EventPage(eventId: event.id!)
                        } label: {
                            EventPreview(eventPreview: event)
                        }
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
                    document in EventModel(data: document.data(), id: document.documentID)
                }
        }
    }
}

struct ExploreEventsPage_Previews: PreviewProvider {
    static var previews: some View {
        ExploreEventsPage()
            .environmentObject(UserManager())
    }
}
