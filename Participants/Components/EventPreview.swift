//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import FirebaseStorage

struct EventPreview: View {
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

            ZStack {
                if let imageUrl = imageUrl {
                    AsyncImage(
                        url: imageUrl,
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                             .frame(maxHeight: 150)
                                             .clipped()
                                    },
                                    placeholder: {
                                        ProgressView()
                                    }
                    )
                }
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(eventPreview.description)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("Attending: \(eventPreview.peopleAttending.count)")
                        .multilineTextAlignment(.leading)
                    Text("Thinking: \(eventPreview.peopleThinking.count)")
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(height: 100.0)
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

struct EventPreview_Previews: PreviewProvider {
    static var previews: some View {
        EventPreview(eventPreview: EventModel(title: "Test", description: "Description", imagePreview: "user/oqf0IbCqDfYWwO0pGHaLnH4EYBe2/13C7D6AC-C8C7-40F0-8E2D-BF7B93E0C883.png", startDate: "2023-01-05T18:54:19Z", address: "Pushkin street", authorId: "ErWgEodvZnMgQ20MDgR0", peopleAttending: [], peopleThinking: []))
    }
}
