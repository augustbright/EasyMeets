//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import Foundation

struct EventModel: Identifiable {
    var id: String?
    var title: String
    var description: String
    var imagePreview: String?
    var startDate: String
    var finishDate: String?
    var address: String
    var longtitude: Double?
    var latitude: Double?
    var authorId: String
    var communityId: String?
    var attending: AttendingStatus?
    
    var peopleAttending: [String]
    var peopleThinking: [String]

    var startDateFormatted: Date? {
        let newFormatter = ISO8601DateFormatter()
        return newFormatter.date(from: startDate)
    }

    enum AttendingStatus: String {
        case Attending = "attending", Thinking = "thinking"
    }
}
