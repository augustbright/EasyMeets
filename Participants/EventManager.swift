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
    func saveEvent(_ model: EventModel, id: String?, completion: @escaping (String?, Error?) -> Void) {
        let db = Firestore.firestore()
        if let id {
            db.collection("Events").document(id).updateData(model.dictionary) {
                error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                completion(id, nil)
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
    
    static func deleteEvent(_ eventId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("Events").document(eventId).updateData([
            "deleted": true
        ]) {
            error in completion(error)
        }

    }
}
