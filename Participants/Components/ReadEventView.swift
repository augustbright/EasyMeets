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
    
    @State private var imageUrl: URL?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude:  41.715137, longitude: 44.807095),
        latitudinalMeters: 3000,
        longitudinalMeters: 3000
    )
    @State private var location: Location?
    
    var body: some View {
        List() {
            Section(header: VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title3)
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 4.0)
                HStack {
                    Label("Time", systemImage: "calendar")
                        .labelStyle(.iconOnly)
                    Text(event.startDateFormatted, style: .date)
                    Text(event.startDateFormatted, style: .time).bold()
                }
                if let address = event.address {
                    Text(address)
                        .foregroundColor(Color.gray)
                }
            }) {
                if let communityId = event.communityId, let communityName = event.communityName {
                    LabeledContent("By") {
                        NavigationLink  {
                            CommunityPage(communityId: communityId)
                        } label: {
                            Label(communityName, systemImage: "person.3.sequence.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    LabeledContent("By") {
                        NavigationLink  {
                            Text(event.authorName)
                        } label: {
                            Text(event.authorName)
                        }
                    }
                }

                Section() {
                    VStack(alignment: .leading) {
                        if !event.isOnline, let location {
                            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: [location]) {
                                (location) -> MapPin in MapPin(coordinate: location.coordinate)
                            }
                            .frame(height: 200.0)
                        }
                        if event.isOnline, let eventLink = event.eventLink {
                            Text("This is an online event")
                            Link("Link to event", destination: URL(string: eventLink)!)
                                .buttonStyle(.bordered)
                        }
                        if let locationInfo = event.locationAdditionalInfo, !locationInfo.isEmpty {
                            Text(locationInfo)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        if let imageUrl = imageUrl {
                            AsyncImage(
                                url: imageUrl,
                                content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                },
                                placeholder: {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                }
                            )
                            .background(Color(.secondarySystemBackground))
                            .clipped()
                            
                        }
                        
                        Text(event.description)
                            .multilineTextAlignment(.leading)
                    }
                }


            }        }
        .listStyle(.plain)
        .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    EventControlsView(eventId: event.id!) {
                        onEditEvent()
                    }
                }
        }
        .onAppear {
            if !event.isOnline, let longtitude = event.longtitude, let latitude = event.latitude {
                let coordinate = CLLocationCoordinate2D(latitude:  latitude, longitude: longtitude)
                region.center = coordinate
                location = Location(title: "Event location", coordinate: coordinate)
            }
            
            fetchImage()
        }
        
    }
    
    func fetchImage() {
        if let image = event.image {
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child(image)
            
            imageRef.downloadURL() {
                (url, error) in
                guard error == nil else {
                    return
                }
                
                self.imageUrl = url
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
