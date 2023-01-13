//
//  EventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase
import FirebaseStorage
import MapKit

struct EventView: View {
    var event: EventModel
    
    @State private var actualEvent: EventModel?
    @State private var isEditing = false
    @State private var error: Error?
        
    var body: some View {
        VStack {
            if let actualEvent, !isEditing {
                ReadEventView(event: actualEvent) {
                    isEditing = true
                }
            } else {
                EditEventView(originalEvent: event) {
                    event, error in
                    guard error == nil else {
                        self.error = error
                        return
                    }
                    actualEvent = event
                    isEditing = false
                }
            }
        }
        .onAppear {
            actualEvent = event
        }
    }
    
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventView(event: EventModel.mock)
                .environmentObject(UserManager())
        }
    }
}
