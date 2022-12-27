//
//  CommunityModel.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import Foundation

struct CommunityModel: Codable, Identifiable {
    var id: Int;
    var name: String;
    var about: String;
    var followers: Int;
    var image: String;
    var isFollowed: Bool;
}
