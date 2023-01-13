//
//  CommunityModel.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import Foundation

struct CommunityModel: Codable, Identifiable, Hashable {
    var id: String?;
    var authorId: String;
    var name: String;
    var description: String;
    var followers: [String];
    var image: String?;
}

struct CommunityPickerItem: Identifiable {
    var id: String;
    var name: String;
}
