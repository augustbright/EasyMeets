//
//  UserManager.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.12.2022.
//

import Foundation
import FirebaseAuth
import SwiftUI
import Firebase

let autoLogin = false

class UserManager: ObservableObject {
    @Published var user: User?
    @Published var userInfo: UserInfoModel?
    @Published var error: Error?;
    @Published var message: String = ""
    @Published var isLoading: Bool = false

    private var userInfoListeningRegistration: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
        if autoLogin {
            self.signIn(withEmail: "", password: "") {
                _, _ in
            }
        }

        listen()
    }
    
    func signIn(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        self.isLoading = true
        self.message = "Loading"
        Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] (result, error) in
            guard let self = self else { return }
            self.message = "Loaded"
            self.isLoading = false

            guard error == nil else {
                self.error = error
                return
            }
            self.error = nil
            if let completion {
                completion(result, error)
            }
        }
    }
    
    private func listen() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
            self.ensureUserInfo() {
                error in
                guard error == nil else {
                    self.message = error.debugDescription
                    return
                }
                self.listenUserInfo()
            }
        }
    }

    private func ensureUserInfo(completion: @escaping ((Error?) -> Void)) {
        self.message = "Ensuring"

        if let userInfoListeningRegistration {
            userInfoListeningRegistration.remove()
        }
        guard let userId = self.user?.uid else {
            return
        }
        self.message = "got userId"
        let userRef = self.db.collection("Users").document(userId)
        userRef.getDocument() {
            (document, error) in
            self.message = "got user document"
            if let document, !document.exists {
                self.message = "user doesn't exist"
                self.db.collection("Users").document(userId).setData(UserManager.dataFromUserInfo(UserInfoModel(
                    eventsAttending: [],
                    eventsMaybe: [],
                    eventsStarred: []
                )), completion: completion)
            } else {
                completion(nil)
            }
        }
    }

    private func listenUserInfo() {
        if let userInfoListeningRegistration {
            userInfoListeningRegistration.remove()
        }
        guard let userId = self.user?.uid else {
            return
        }

        let userRef = self.db.collection("Users").document(userId)
        self.userInfoListeningRegistration = userRef.addSnapshotListener() {
            (document, error) in
            guard error == nil else {
                return
            }
            if let document, document.exists, let data = document.data() {
                self.userInfo = UserManager.userInfoFromData(data)
            }
        }
    }
    
    static func dataFromUserInfo(_ model: UserInfoModel) -> [String: Any] {
        return [
            "eventsAttending": model.eventsAttending,
            "eventsMaybe": model.eventsMaybe,
            "eventsStarred": model.eventsStarred
        ]
    }

    
    static func userInfoFromData(_ data: [String: Any]) -> UserInfoModel {
        return UserInfoModel(
            eventsAttending: (data["eventsAttending"] ?? []) as! [String],
            eventsMaybe: (data["eventsMaybe"] ?? []) as! [String],
            eventsStarred: (data["eventsStarred"] ?? []) as! [String]
        )
    }
    
    func attendEvent(eventId: String) {
        guard let userId = self.user?.uid else {
            return
        }

        let userRef = self.db.collection("Users").document(userId)
        userRef.updateData([
            "eventsAttending": FieldValue.arrayUnion([eventId]),
            "eventsMaybe": FieldValue.arrayRemove([eventId])
        ])
        
        let eventRef = self.db.collection("Events").document(eventId)
        eventRef.updateData([
            "peopleAttending": FieldValue.arrayUnion([userId]),
            "peopleMaybe": FieldValue.arrayRemove([userId])
        ])
    }
    
    func maybeEvent(eventId: String) {
        guard let userId = self.user?.uid else {
            return
        }

        let userRef = self.db.collection("Users").document(userId)
        userRef.updateData([
            "eventsMaybe": FieldValue.arrayUnion([eventId]),
            "eventsAttending": FieldValue.arrayRemove([eventId])
        ])
        let eventRef = self.db.collection("Events").document(eventId)
        eventRef.updateData([
            "peopleAttending": FieldValue.arrayRemove([userId]),
            "peopleMaybe": FieldValue.arrayUnion([userId])
        ])
    }
    
    func toggleStarEvent(eventId: String, isSet: Bool) {
        guard let userId = self.user?.uid else {
            return
        }

        let userRef = self.db.collection("Users").document(userId)
        if isSet {
            userRef.updateData([
                "eventsStarred": FieldValue.arrayUnion([eventId])
            ])
        } else {
            userRef.updateData([
                "eventsStarred": FieldValue.arrayRemove([eventId])
            ])
        }
    }
    
    func leaveEvent(eventId: String) {
        guard let userId = self.user?.uid else {
            return
        }

        let userRef = self.db.collection("Users").document(userId)
        userRef.updateData([
            "eventsMaybe": FieldValue.arrayRemove([eventId]),
            "eventsAttending": FieldValue.arrayRemove([eventId])
        ])
        let eventRef = self.db.collection("Events").document(eventId)
        eventRef.updateData([
            "peopleAttending": FieldValue.arrayRemove([userId]),
            "peopleMaybe": FieldValue.arrayRemove([userId])
        ])

    }
}