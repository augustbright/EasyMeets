//
//  EventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct EventPage: View {
    var event: EventPreviewData
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: event.imagePreview)).frame(height: 240.0).scaledToFill()

            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    
                HStack {
                    Text(event.startDateFormatted!, style: .date)
                    Text(event.startDateFormatted!, style: .time)
                }
                Text(event.address)
                    .foregroundColor(Color.gray)

                HStack(spacing: 20.0) {
                    Button("I'm in (\(event.peopleAttending))", action: {})
                        .buttonStyle(.borderedProminent)
                    Button("Maybe (\(event.peopleThinking))", action: {})
                    Spacer()
                    Button {} label: {
                        Label("Toggle favorite", systemImage: "star").labelStyle(.iconOnly)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical)

                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(event.description)
                            .multilineTextAlignment(.leading)
                    }
                }

            }
            .padding([.top, .leading, .trailing])
            Spacer()
        }
        
    }
}

struct EventPage_Previews: PreviewProvider {
    static var data = DataModel()
    static var previews: some View {
        EventPage(event: data.eventPreviews[0])
    }
}
