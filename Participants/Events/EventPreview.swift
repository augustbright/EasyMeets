//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import FirebaseFirestore

struct EventPreview: View {
    var eventPreview: EventModel
    @State private var imageUrl: URL?
    
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")

        return dateFormatter.string(from: eventPreview.startDateFormatted)
    }

    var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")

        return dateFormatter.string(from: eventPreview.startDateFormatted)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(date)
                        .bold()
                    Text(eventPreview.startDateFormatted, style: .time)
                    .font(.caption)
                }
                Text(dayOfWeek)

                Spacer()
                
                VStack(alignment: .center) {
                    Text(eventPreview.peopleAttending.count.formatted())
                        .bold()
                    Text("Attending")
                        .font(.caption)
                }
            }
            
            Text(eventPreview.description)
                .multilineTextAlignment(.leading)
                .padding(.top)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct EventPreview_Previews: PreviewProvider {
    static var previews: some View {
        EventPreview(eventPreview: EventModel.mock)
            .frame(height: 250)
    }
}
