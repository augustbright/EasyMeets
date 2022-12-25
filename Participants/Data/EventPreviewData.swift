//
//  EventPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import Foundation

struct EventPreviewData: Codable, Identifiable {
    var id: Int
    var title: String
    var description: String
    var imagePreview: String
    private var startDate: String
    var finishDate: String?
    var address: String
    var longtitude: Float
    var latitude: Float
    var author: Author
    var community: Community
    var isFavorite: Bool;
    var peopleAttending: Int;
    var peopleThinking: Int;
    
    var startDateFormatted: Date? {
        let newFormatter = ISO8601DateFormatter()
        return newFormatter.date(from: startDate)
    }

    struct Author: Codable {
        var id: Int;
        var fullName: String;
    }
    
    struct Community: Codable {
        var id: Int?;
        var name: String;
    }
}
