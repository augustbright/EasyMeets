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
    @State private var events: [EventModel]?
    @State private var error: Error?
    
    var body: some View {
        VStack {
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
                .toolbar() {
                    ToolbarItem() {
                        NavigationLink {
                            CreateEventPage()
                        } label: {
                            Label("Let's meet", systemImage: "plus.app")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
                .navigationTitle("Easy Meets")
                .searchable(text: $searchText)
            }
        }
        .onAppear() {
            self.fetchEvents()
        }
    }
    
    func fetchEvents() {
        let db = Firestore.firestore()
        let collection = db.collection("Events").whereField("deleted", isNotEqualTo: true)
        
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
        NavigationStack {            
            ExploreEventsPage()
                .environmentObject(UserManager())
        }
    }
}
