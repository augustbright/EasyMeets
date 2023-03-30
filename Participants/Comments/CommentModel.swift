//
//  CommentModel.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 23.03.2023.
//

import Foundation
import FirebaseFirestore

struct CommentModel {
    var content: String
    var likes: [String]
    var authorId: String
    var authorName: String
    var dateTimeCreated: Timestamp
    var dateTimeEdited: Timestamp?
    var deleted: Bool?
    var replySectionId: String?
    
    init(dateTimeCreated: Timestamp, dateTimeEdited: Timestamp? = nil, authorId: String, authorName: String, content: String, deleted: Bool, likes: [String], replySectionId: String? = nil) {
        self.dateTimeCreated = dateTimeCreated
        self.dateTimeEdited = dateTimeEdited
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.deleted = deleted
        self.likes = likes
        self.replySectionId = replySectionId
    }
    
    init(data: [String: Any]) {
        self.dateTimeCreated = data["dateTimeCreated"] as! Timestamp
        self.dateTimeEdited = data["dateTimeEdited"] as? Timestamp
        self.authorId = data["authorId"] as! String
        self.authorName = (data["authorName"] ?? "") as! String
        self.content = data["content"] as! String
        self.deleted = data["deleted"] as? Bool
        self.likes = data["likes"] as! [String]
        self.replySectionId = data["replySectionId"] as? String
    }
    
    var timeCreated: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'at' HH:mm:ss"

        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(dateTimeCreated.seconds)))
    }

    static var mock = CommentModel(dateTimeCreated: Timestamp(), dateTimeEdited: nil, authorId: "4bR1KOGJF0Vbm2uck2ibQUEfJBz1", authorName: "Admin", content: "Life is like a box of chocolates, you never know what you're gonna get.", deleted: false, likes: [], replySectionId: "4bR1KOGJF0Vbm2uck2ibQUEfJBz1")
}
