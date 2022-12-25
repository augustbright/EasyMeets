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
                AsyncImage(url: URL(string: eventPreview.imagePreview))
                    .frame(width: 100.0, height: 100.0)
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
        EventPreview(eventPreview: data.eventPreviews[0])
    }
}
