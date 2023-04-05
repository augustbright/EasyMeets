//
//  ExploreEventsPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 09.01.2023.
//

import SwiftUI
import Firebase

struct ExploreEventsPage: View {
    var isActive: Bool

    @State private var searchText = ""
    @State private var events: [EventModel]?
    @State private var error: Error?
    @StateObject private var plansObserver = PlansObserver()
    
    private var todayPlanned: [EventModel] {
        guard let events = plansObserver.plannedTodayEvents else {
            return []
        }
        return events
    }
    
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        VStack() {
            ScrollView {
                FeedbackRequest()
                    .padding()
                if let events = events {
                    VStack(alignment: .leading) {
                        HStack{Spacer()}
                        if todayPlanned.count == 0 {
                            Text("No plans for today")
                                .foregroundColor(.secondary)
                        } else {
                            Text("Your Plans for Today")
                                .font(.title2)
                            EventsList(events: todayPlanned)
                        }

                        HStack {
                            NavigationLink("See All My Plans")  {
                                MyPlansPage()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding([.horizontal])
                    
                    VStack {
                        Text("Discover More Events")
                            .font(.title3)
                            .padding(.top)
                        ForEach(events) { event in
                            NavigationLink  {
                                EventPage(eventId: event.id!)
                            } label: {
                                EventPreview(eventPreview: event)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .toolbar() {
            if self.isActive {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        CreateEventPage()
                    } label: {
                        Label("Let's Meet", systemImage: "plus.app")
                            .labelStyle(.titleOnly)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Easy Meets")
        .onAppear() {
            self.fetchEvents()
            self.plansObserver.setUserInfo(userManager.userInfo, userManager.user)
        }
        .onChange(of: userManager.userInfo) {
            userInfo in
            self.plansObserver.setUserInfo(userManager.userInfo, userManager.user)
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
            ExploreEventsPage(isActive: true)
                .environmentObject(UserManager())
        }
    }
}
