//
//  UserInfoModel.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 10.01.2023.
//

import Foundation

struct UserInfoModel {
    var displayName: String
    var avatar: String?
    var bio: String
    var interests: [String]
    
    var subscribers: [String]
    var invitations: [String]

    var eventsAttending: [String]
    var eventsMaybe: [String]
    var eventsStarred: [String]

    var eventsOwn: [String]
    var communitiesOwn: [String]
    
    var usersSubscriptions: [String]
    var communitiesSubscriptions: [String]
    var usersBlackList: [String]
    var communitiesBlackList: [String]
}
