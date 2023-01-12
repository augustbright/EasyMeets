//
//  CommunityManager.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 07.01.2023.
//

import UIKit
import Firebase

class CommunityManager {
    static func dataFromCommunity(_ model: CommunityModel) -> [String: Any] {
        return [
            "authorId": model.authorId,
            "dateCreated": Timestamp(date: Date()),

            "name": model.name,
            "description": model.description,
            "image": model.image,
            "followers": model.followers
        ]
    }

    static func communityFromData(_ data: [String: Any], _ id: String) -> CommunityModel {
        return CommunityModel(
            id: id,
            authorId: data["authorId"] as! String,
            name: data["name"] as! String,
            description: data["description"] as! String,
            followers: data["followers"] as! [String],
            image: data["image"] as? String
        )
    }
}
