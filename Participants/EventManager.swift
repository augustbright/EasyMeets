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
    func createEvent(_ model: EventModel, completion: @escaping (String?, Error?) -> Void) {
        let db = Firestore.firestore()
        var newEventRef: DocumentReference?
        newEventRef = db.collection("Events").addDocument(data: model.dictionary) {
            error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(newEventRef!.documentID, nil)
        }
    }
}
