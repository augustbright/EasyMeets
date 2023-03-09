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
                Text(eventPreview.startDateFormatted, style: .date)
                Text(eventPreview.startDateFormatted, style: .time)
            }
            if let address = eventPreview.address {
                Text(address)
                    .foregroundColor(Color.gray)
            }
            EventControlsView(eventId: eventPreview.id!) {}
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

struct EventPreviewSmall_Previews: PreviewProvider {
    static var previews: some View {
        EventPreviewSmall(eventPreview: EventModel.mock)
        
    }
}
