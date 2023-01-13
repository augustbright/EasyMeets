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
    func saveEvent(_ model: EventModel, completion: @escaping (String?, Error?) -> Void) {
        let db = Firestore.firestore()
        if let eventId = model.id {
            db.collection("Events").document(eventId).updateData(model.dictionary) {
                error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                completion(eventId, nil)
            }
        } else {
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
}
