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

struct ReadEventView: View {
    var event: EventModel
    var onEditEvent: () -> Void
    @EnvironmentObject private var userManager: UserManager
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:  41.715137, longitude: 44.807095),
        latitudinalMeters: 3000,
        longitudinalMeters: 3000
    )
    @State private var location: Location?
    
    var userHasParticipated: Bool {
        guard let userId = self.userManager.user?.uid else {
            return false
        }
        let userAttended = event.peopleAttending.contains(userId)
        let eventPassed = NSCalendar.current.dateComponents([.hour], from: event.startDateFormatted, to: Date()).hour ?? 0 > 3
        
        return userAttended && eventPassed
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Label("Time", systemImage: "calendar")
                        .labelStyle(.iconOnly)
                    Text(event.startDateFormatted, style: .date)
                    Text(event.startDateFormatted, style: .time).bold()
                    Spacer()
                }
                .padding(.bottom, 2)
                HStack {
                    Text("By")
                        .font(.caption)
                    NavigationLink  {
                        UserProfileView(userId: event.authorId, isActive: true)
                    } label: {
                        Text(event.authorName)
                    }
                    Spacer()
                }
                
                if let eventId = event.id, userHasParticipated {
                    FeedbackArea(eventId: eventId)
                        .padding(.vertical)
                        .shadow(radius: 2)
                }
                
                VStack(alignment: .leading) {
                    Text(event.description)
                        .multilineTextAlignment(.leading)
                }

                Section() {
                    VStack(alignment: .leading) {
                        if let location {
                            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: [location]) {
                                (location) -> MapPin in MapPin(coordinate: location.coordinate)
                            }
                            .frame(height: 200.0)
                        }

                        if !event.locationAdditionalInfo.isEmpty {
                            Text(event.locationAdditionalInfo)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                if let eventId = event.id {
                    Text("Comments")
                        .font(.title2)
                    Comments(eventId: eventId)
                }
            }
        }
        .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if let eventId = event.id {
                        EventControlsView(eventId: eventId) {
                            onEditEvent()
                        }
                    }
                }
        }
        .onAppear {
            if let longtitude = event.longtitude, let latitude = event.latitude {
                let coordinate = CLLocationCoordinate2D(latitude:  latitude, longitude: longtitude)
                region.center = coordinate
                location = Location(title: "Event location", coordinate: coordinate)
            }
        }
        
    }
}

struct ReadEventView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReadEventView(event: EventModel.mock) {}
                .environmentObject(UserManager())
        }
    }
}
