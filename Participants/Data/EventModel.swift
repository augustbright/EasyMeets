//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import Foundation
import FirebaseFirestore

struct EventModel: Identifiable {
    var id: String?
    var title: String
    var dateCreated: String?

    var authorId: String
    var authorName: String
    var communityId: String?
    var communityName: String?

    var startDate: String
    var finishDate: String?

    var image: String?

    var isOnline: Bool
    var longtitude: Double?
    var latitude: Double?
    var address: String?
    var eventLink: String?
    var locationAdditionalInfo: String

    var description: String
    
    var published: Bool
    var deleted: Bool?

    var peopleAttending: [String]
    var peopleThinking: [String]
    
    init(id: String? = nil, title: String, dateCreated: String? = nil, authorId: String, authorName: String, communityId: String? = nil, communityName: String? = nil, startDate: String, finishDate: String? = nil, image: String? = nil, isOnline: Bool, longtitude: Double? = nil, latitude: Double? = nil, address: String? = nil, eventLink: String? = nil, locationAdditionalInfo: String, description: String, published: Bool, deleted: Bool, peopleAttending: [String], peopleThinking: [String]) {
        self.id = id
        self.title = title
        self.dateCreated = dateCreated
        self.authorId = authorId
        self.authorName = authorName
        self.communityId = communityId
        self.communityName = communityName
        self.startDate = startDate
        self.finishDate = finishDate
        self.image = image
        self.isOnline = isOnline
        self.longtitude = longtitude
        self.latitude = latitude
        self.address = address
        self.eventLink = eventLink
        self.locationAdditionalInfo = locationAdditionalInfo
        self.description = description
        self.published = published
        self.deleted = deleted
        self.peopleAttending = peopleAttending
        self.peopleThinking = peopleThinking
    }

    init(data: [String: Any], id: String?) {
        self.id = id
        self.title = data["title"] as! String
        self.dateCreated = data["dateCreated"] as? String
        self.authorId = data["authorId"] as! String
        self.authorName = data["authorName"] as! String
        self.communityId = data["communityId"] as? String
        self.communityName = data["communityName"] as? String
        self.startDate = data["startDate"] as! String
        self.finishDate = data["finishDate"] as? String
        self.image = data["image"] as? String
        self.isOnline = data["isOnline"] as! Bool
        self.longtitude = data["longtitude"] as? Double
        self.latitude = data["latitude"] as? Double
        self.address = data["address"] as? String
        self.eventLink = data["eventLink"] as? String
        self.locationAdditionalInfo = data["locationAdditionalInfo"] as! String
        self.description = data["description"] as! String
        self.published = data["published"] as! Bool
        self.deleted = data["deleted"] as? Bool
        self.peopleAttending = data["peopleAttending"] as! [String]
        self.peopleThinking = data["peopleThinking"] as! [String]
    }
    
    var dictionary: [String: Any] {
        return [
            "title": title,
            "dateCreated": Timestamp(date: Date()),

            "authorId": authorId,
            "authorName": authorName,
            "communityId": communityId,
            "communityName": communityName,

            "startDate": startDate,
            "finishDate": finishDate,

            "image": image,

            "isOnline": isOnline,
            "longtitude": longtitude,
            "latitude": latitude,
            "address": address,
            "eventLink": eventLink,
            "locationAdditionalInfo": locationAdditionalInfo,
            
            "description": description,

            "published": published,
            "deleted": deleted,
            "peopleAttending": peopleAttending,
            "peopleThinking": peopleThinking,

        ]
    }
    
    var startDateFormatted: Date {
        let newFormatter = ISO8601DateFormatter()
        return newFormatter.date(from: startDate)!
    }

    var finishDateFormatted: Date? {
        guard let finishDate else { return nil }
        let newFormatter = ISO8601DateFormatter()
        return newFormatter.date(from: finishDate)
    }

    static var mock = EventModel(id: "id1", title: "Test", dateCreated: nil, authorId: "ErWgEodvZnMgQ20MDgR0", authorName: "Pushkin", communityId: "09PrhMEmZ4eFmGEeY2D1", communityName: "Swifters", startDate: "2023-01-05T18:54:19Z", finishDate: "2023-01-06T18:54:19Z", image: "user/oqf0IbCqDfYWwO0pGHaLnH4EYBe2/13C7D6AC-C8C7-40F0-8E2D-BF7B93E0C883.png", isOnline: false, longtitude: 44.802095, latitude:  41.715137, address: "Pushkin street", eventLink: "https://google.com", locationAdditionalInfo: "Station square", description: "An awesome event", published: true, deleted: false, peopleAttending: [], peopleThinking: [])

}
