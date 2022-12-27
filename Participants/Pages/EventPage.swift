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
            if let image = event.imagePreview {
                AsyncImage(url: URL(string: image)).frame(height: 240.0).scaledToFill()
                
            }
            
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
                
                EventControls(eventId: event.id)
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
            .environmentObject(data)
    }
}
