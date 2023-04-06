//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import Foundation
import FirebaseFirestore

struct EventModel: Identifiable, Codable {
    var id: String?
    var dateCreated: String?

    var authorId: String
    var authorName: String

    var startDate: String

    var longtitude: Double?
    var latitude: Double?
    var locationAdditionalInfo: String

    var description: String
    var deleted: Bool?

    var peopleAttending: [String]
    
    init(id: String? = nil, dateCreated: String? = nil, authorId: String, authorName: String, startDate: String, longtitude: Double? = nil, latitude: Double? = nil, locationAdditionalInfo: String, description: String, deleted: Bool, peopleAttending: [String]) {
        self.id = id
        self.dateCreated = dateCreated
        self.authorId = authorId
        self.authorName = authorName
        self.startDate = startDate
        self.longtitude = longtitude
        self.latitude = latitude
        self.locationAdditionalInfo = locationAdditionalInfo
        self.description = description
        self.deleted = deleted
        self.peopleAttending = peopleAttending
    }

    init(data: [String: Any], id: String?) {
        self.id = id
        self.dateCreated = data["dateCreated"] as? String
        self.authorId = data["authorId"] as! String
        self.authorName = (data["authorName"] ?? "") as! String
        self.startDate = data["startDate"] as! String
        self.longtitude = data["longtitude"] as? Double
        self.latitude = data["latitude"] as? Double
        self.locationAdditionalInfo = (data["locationAdditionalInfo"] ?? "") as! String
        self.description = data["description"] as! String
        self.deleted = data["deleted"] as? Bool
        self.peopleAttending = data["peopleAttending"] as! [String]
    }
    
    var dictionary: [String: Any] {
        return [
            "dateCreated": Timestamp(date: Date()),

            "authorId": authorId,
            "authorName": authorName,
            "startDate": startDate,
            "longtitude": longtitude,
            "latitude": latitude,
            "locationAdditionalInfo": locationAdditionalInfo,
            "description": description,
            "deleted": deleted,
            "peopleAttending": peopleAttending
        ]
    }
    
    var startDateFormatted: Date {
        let newFormatter = ISO8601DateFormatter()
        return newFormatter.date(from: startDate)!
    }

    static var mock = EventModel(id: "3HDdQMelcKrh17vFWZB2", dateCreated: nil, authorId: "ErWgEodvZnMgQ20MDgR0", authorName: "Pushkin",  startDate: "2022-01-15T18:54:19Z", longtitude: 44.802095, latitude:  41.715137, locationAdditionalInfo: "Station square", description: "An awesome event", deleted: false, peopleAttending: ["4bR1KOGJF0Vbm2uck2ibQUEfJBz1"])
}
