//
//  DataModel.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import Foundation
import Combine

final class DataModel: ObservableObject {
    @Published var eventPreviews: [EventPreviewData] = load("Event previews.json")
    @Published var communities: [CommunityModel] = load("Communities.json")
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
