//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct EventPreview: View {
    var eventPreview: EventModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(eventPreview.title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            HStack {
                Text(eventPreview.startDateFormatted!, style: .date)
                Text(eventPreview.startDateFormatted!, style: .time)
            }
            Text(eventPreview.address)
                .foregroundColor(Color.gray)

            HStack(alignment: .top) {
//                if let image = eventPreview.imagePreview {
//                    AsyncImage(
//                        url: URL(string:image),
//                                    content: { image in
//                                        image.resizable()
//                                             .aspectRatio(contentMode: .fit)
//                                             .frame(maxWidth: 100, maxHeight: 100)
//                                    },
//                                    placeholder: {
//                                        ProgressView()
//                                            .frame(width: 100.0, height: 100.0)
//                                    }
//                    )
//                }
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
    }
}

struct EventPreview_Previews: PreviewProvider {
    static var data = DataModel()
    static var previews: some View {
        EventPreview(eventPreview: EventModel(title: "Test", description: "Description", startDate: "2023-01-05T18:54:19Z", address: "Pushkin street", authorId: "ErWgEodvZnMgQ20MDgR0", peopleAttending: [], peopleThinking: []))
    }
}
