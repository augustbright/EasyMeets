//
//  EditEventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 11.01.2023.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ManageEvent: View {
    var eventId: String
    @State private var event: EventModel?
    @State private var error: Error?
    @State private var imageUrl: URL?
    
    @State private var title: String = ""

    var body: some View {
        Form {
            Section {
                    TextField("Title", text: $title)
                HStack {
                    Spacer()
                    Button("Save") {}
                        .buttonStyle(.borderedProminent)
                }
            }

        }
        .onAppear() { fetchEvent() }
    }

    func fetchEvent() {
        let db = Firestore.firestore()
        let eventRef = db.collection("Events").document(eventId)
        eventRef.getDocument() {
            (document, error) in
            guard error == nil else {
                self.error = error
                return
            }
            if let document, document.exists, let data = document.data() {
                let event = EventManager.eventFromData(data, document.documentID)
                self.event = event
                
                self.title = event.title

                if let image = event.imagePreview {
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

struct ManageEvent_Previews: PreviewProvider {
    static var previews: some View {
        ManageEvent(eventId: "ErWgEodvZnMgQ20MDgR0")
    }
}
