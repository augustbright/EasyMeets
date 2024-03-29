//
//  UserInfoModel.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 10.01.2023.
//

import Foundation

struct UserInfoModel: Equatable {
    var displayName: String
    var eventsAttending: [String]
    var eventsOwn: [String]
}
