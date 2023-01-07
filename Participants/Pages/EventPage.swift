//
//  EventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct EventPage: View {
    var eventId: String

    @State private var error: Error?
    @State private var event: EventModel?
    @State private var imageUrl: URL?
    
    var body: some View {
        ScrollView() {
            HStack {
                Spacer()
            }
            if let error = error {
                Text(error.localizedDescription)
            }
            if let event  = event {
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
                    .frame(maxHeight: 300)
                    .background(Color(.secondarySystemBackground))
                    .clipped()
                    
                }
                
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 4.0)
                    
                    HStack {
                        Label("Time", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                        Text(event.startDateFormatted!, style: .date)
                        Text(event.startDateFormatted!, style: .time).bold()
                    }
                    Text(event.address)
                        .foregroundColor(Color.gray)

                    Divider()

                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(event.description)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                }
                .padding([.top, .leading, .trailing])
            } else {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView("Loading event")
                    Spacer()
                }
            }
            Spacer()
        }
        .onAppear() {
            self.fetchEvent(eventId)
        }
    }
    
    func fetchEvent(_ eventId: String) {
        let db = Firestore.firestore()
        let eventRef = db.collection("Events").document(eventId)
        eventRef.getDocument() {
            (document, error) in
            guard error == nil else {
                self.error = error
                return
            }
            if let document, document.exists, let data = document.data() {
                self.event = EventManager.eventFromData(data, document.documentID)
                
                if let image = event?.imagePreview {
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
    }
    
}

struct EventPage_Previews: PreviewProvider {
    static var data = DataModel()
    static var previews: some View {
        EventPage(eventId: "ErWgEodvZnMgQ20MDgR0")
            .environmentObject(data)
    }
}
