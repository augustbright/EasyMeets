//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct EventPreview: View {
    var eventPreview: EventPreviewData
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
                if let image = eventPreview.imagePreview {
                    AsyncImage(
                        url: URL(string:image),
                                    content: { image in
                                        image.resizable()
                                             .aspectRatio(contentMode: .fit)
                                             .frame(maxWidth: 100, maxHeight: 100)
                                    },
                                    placeholder: {
                                        ProgressView()
                                            .frame(width: 100.0, height: 100.0)
                                    }
                    )
                }
                VStack(alignment: .leading) {
                    Text(eventPreview.description)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("Attending: \(eventPreview.peopleAttending)")
                        .multilineTextAlignment(.leading)
                    Text("Thinking: \(eventPreview.peopleThinking)")
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
        EventPreview(eventPreview: data.eventPreviews[2])
    }
}
