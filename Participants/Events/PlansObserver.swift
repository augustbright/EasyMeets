//
//  PlansObserver.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.03.2023.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class PlansObserver: ObservableObject {
    @State var userInfo: UserInfoModel?
    init() {}
    
    @State private var plannedEventsListener: ListenerRegistration?
    
    @Published var plannedEvents: [EventModel]?
    @Published var plannedTodayEvents: [EventModel]?
    @Published var plannedTomorrowEvents: [EventModel]?
    @Published var restPlannedEvents: [EventModel]?
        
    func setUserInfo(_ userInfo: UserInfoModel?) {
        self.userInfo = userInfo
        if let plannedEventsListener {
            plannedEventsListener.remove()
            setEvents(nil)
        }
        
        guard let userInfo else { return }
        
        self.plannedEventsListener = Firestore.firestore()
            .collection("Events")
            .whereField(FieldPath.documentID(), in: userInfo.eventsAttending)
            .whereField("deleted", isEqualTo: false)
            .addSnapshotListener() {
                (querySnapshot, error) in
                guard error == nil else {
                    self.plannedEvents = nil
                    return
                }
                
                let plannedEvents = querySnapshot!.documents.map() {
                    document in EventModel(data: document.data(), id: document.documentID)
                }
                
                self.setEvents(plannedEvents)
            }
    }
    
    func setEvents(_ events: [EventModel]?) {
        guard let events else {
            self.plannedEvents = nil
            self.plannedTodayEvents = nil
            self.plannedTomorrowEvents = nil
            self.restPlannedEvents = nil
            return
        }
        
        self.plannedTodayEvents = events.filter { event in NSCalendar.current.isDateInToday(event.startDateFormatted) }
        self.plannedTomorrowEvents = events.filter { event in NSCalendar.current.isDateInTomorrow(event.startDateFormatted)}
        self.restPlannedEvents = events.filter { event in !NSCalendar.current.isDateInToday(event.startDateFormatted) && !NSCalendar.current.isDateInTomorrow(event.startDateFormatted) }
    }
}
