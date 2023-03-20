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
            HStack {
                Text(eventPreview.startDateFormatted, style: .date)
                Text(eventPreview.startDateFormatted, style: .time)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(eventPreview.description)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("Attending: \(eventPreview.peopleAttending.count)")
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding()
    }
}

struct EventPreview_Previews: PreviewProvider {
    static var previews: some View {
        EventPreview(eventPreview: EventModel.mock)
    }
}
