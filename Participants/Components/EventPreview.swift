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
            if let address = eventPreview.address {
                Text(address)
                    .foregroundColor(Color.gray)
            }

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
        if let image = eventPreview.image {
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
        EventPreview(eventPreview: EventModel.mock)
    }
}
