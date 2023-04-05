//
//  PlansObserver.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.03.2023.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class PlansObserver: ObservableObject {
    private var userInfo: UserInfoModel? = nil
    private var user: User? = nil
    private var plannedEventsListener: ListenerRegistration?
    private var eventForFeedbackListener: ListenerRegistration?
    init() {}
    
    @Published var plannedEvents: [EventModel]?
    @Published var plannedTodayEvents: [EventModel]?
    @Published var plannedTomorrowEvents: [EventModel]?
    @Published var restPlannedEvents: [EventModel]?
    @Published var passedEvents: [EventModel]?
    @Published var eventForFeedback: EventModel?
        
    func setUserInfo(_ userInfo: UserInfoModel?, _ user: User?) {
        self.userInfo = userInfo
        self.user = user
        if let plannedEventsListener {
            plannedEventsListener.remove()
            setEvents(nil)
        }
        
        guard let userInfo = self.userInfo, let user = self.user else {
            return
        }
        
        if userInfo.eventsAttending.isEmpty {
            self.setEvents(nil)
            return
        }
        
        self.plannedEventsListener = Firestore.firestore()
            .collection("Events")
            .whereField(FieldPath.documentID(), in: userInfo.eventsAttending)
            .whereField("deleted", isEqualTo: false)
            .addSnapshotListener() {
                (querySnapshot, error) in
                guard error == nil else {
                    self.setEvents(nil)
                    return
                }
                
                let plannedEvents = querySnapshot!.documents.map() {
                    document in EventModel(data: document.data(), id: document.documentID)
                }.sorted {
                    event1, event2 in (event1.startDateFormatted > event2.startDateFormatted)
                }
                
                self.setEvents(plannedEvents)
            }
    }
    
    func setEvents(_ events: [EventModel]?) {
        if let eventForFeedbackListener {
            eventForFeedbackListener.remove()
        }

        guard let events else {
            self.plannedEvents = nil
            self.plannedTodayEvents = nil
            self.plannedTomorrowEvents = nil
            self.restPlannedEvents = nil
            self.passedEvents = nil
            self.eventForFeedback = nil
            self.eventForFeedbackListener = nil
            return
        }
        
        self.plannedTodayEvents = events.filter { event in NSCalendar.current.isDateInToday(event.startDateFormatted) }
        self.plannedTomorrowEvents = events.filter { event in NSCalendar.current.isDateInTomorrow(event.startDateFormatted)}
        self.restPlannedEvents = events.filter { event in !NSCalendar.current.isDateInToday(event.startDateFormatted) && !NSCalendar.current.isDateInTomorrow(event.startDateFormatted) }
        self.passedEvents = events.filter { event in
            NSCalendar.current.dateComponents([.hour], from: event.startDateFormatted, to: Date()).hour ?? 0 > 3
        }
        
        if let eventForFeedback = passedEvents?.first, let userId = user?.uid {
            self.eventForFeedbackListener = Firestore.firestore()
                .collection("Events")
                .document(eventForFeedback.id!)
                .collection("feedbacks")
                .document(userId)
                .addSnapshotListener() { snapshot, error in
                    guard let snapshot else { return }
                    let data = snapshot.data()
                    if data == nil {
                        self.eventForFeedback = eventForFeedback
                        return
                    }
                    self.eventForFeedback = nil
                }
        }
    }
}
