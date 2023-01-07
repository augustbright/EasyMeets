//
//  EventManager.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.12.2022.
//

import SwiftUI
import Foundation
import FirebaseCore
import Firebase

class EventManager: ObservableObject {
    func createEvent(_ model: EventModel, completion: ((Error?) -> Void)?) -> String {
        let db = Firestore.firestore()
        let data = EventManager.dataFromEvent(model)
        let newEventRef = db.collection("Events").addDocument(data: data, completion: completion)

        return newEventRef.documentID
    }
    
    static func dataFromEvent(_ model: EventModel) -> [String: Any] {
        return [
            "authorId": model.authorId,
            "dateCreated": Timestamp(date: Date()),

            "title": model.title,
            "description": model.description,
            "imagePreview": model.imagePreview,
            "startDate": model.startDate,
            "finishDate": model.finishDate,
            "address": model.address,
            "longtitude": model.longtitude,
            "latitude": model.latitude,
            "communityId": model.communityId,
            "peopleAttending": model.peopleAttending,
            "peopleThinking": model.peopleThinking
        ]
    }

    static func eventFromData(_ data: [String: Any], _ id: String) -> EventModel {
        return EventModel(
            id: id,
            title: data["title"] as! String,
            description: data["description"] as! String,
            imagePreview: data["imagePreview"] as? String,
            startDate: data["startDate"] as! String,
            address: data["address"] as! String,
            authorId: data["authorId"] as! String,
            peopleAttending: data["peopleAttending"] as! [String],
            peopleThinking: data["peopleThinking"] as! [String]
        )

    }
}
