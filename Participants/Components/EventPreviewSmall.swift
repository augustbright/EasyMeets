//
//  EventPreviewSmall.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 11.01.2023.
//

import SwiftUI
import FirebaseStorage

struct EventPreviewSmall: View {
    var eventPreview: EventModel
    @State private var imageUrl: URL?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(eventPreview.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(eventPreview.startDateFormatted!, style: .date)
                Text(eventPreview.startDateFormatted!, style: .time)
            }
            Text(eventPreview.address)
                .foregroundColor(Color.gray)
            EventControlsView(eventId: eventPreview.id!)
        }
        .onAppear() {
            fetchImageUrl()
        }
    }
    
    func fetchImageUrl() {
        if let image = eventPreview.imagePreview {
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

struct EventPreviewSmall_Previews: PreviewProvider {
    static var previews: some View {
        EventPreviewSmall(eventPreview: EventModel(id: "", title: "Test", description: "Description", imagePreview: "user/oqf0IbCqDfYWwO0pGHaLnH4EYBe2/13C7D6AC-C8C7-40F0-8E2D-BF7B93E0C883.png", startDate: "2023-01-05T18:54:19Z", address: "Pushkin street", authorId: "ErWgEodvZnMgQ20MDgR0", peopleAttending: [], peopleThinking: []))
            .environmentObject(UserManager())
        
    }
}
