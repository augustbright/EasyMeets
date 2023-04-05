//
//  FeedbackModel.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.03.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FeedbackModel {
    var authorName: String
    var authorId: String
    var createdAt: Timestamp
    var eventId: String
    var liked: Bool?
        
    init(authorName: String, authorId: String, createdAt: Timestamp, eventId: String, liked: Bool? = nil) {
        self.authorName = authorName
        self.authorId = authorId
        self.createdAt = createdAt
        self.eventId = eventId
        self.liked = liked
    }
}

func createFeedbackData(userInfo: UserInfoModel, user: User) -> [String : Any] {
    return [
        "authorId": user.uid,
        "authorName": userInfo.displayName,
        "createdAt": Timestamp()
    ]
}

func withLiked(_ data: [String : Any]) -> [String : Any] {
    return data.merging(["liked": true]) { $1 }
}

func setFeedback(eventId: String, userId: String, data: [String : Any]) {
    Firestore.firestore()
        .collection("Events")
        .document(eventId)
        .collection("feedbacks")
        .document(userId)
        .setData(data.merging([
            "eventId": eventId
        ], uniquingKeysWith: { $1 }), merge: true)
}

func createFeedbackModelFromData(_ data: [String: Any]) -> FeedbackModel {
    return FeedbackModel(
        authorName: data["authorName"] as! String,
        authorId: data["authorId"] as! String,
        createdAt: data["createdAt"] as! Timestamp,
        eventId: data["eventId"] as! String,
        liked: data["liked"] as? Bool
    )
}
