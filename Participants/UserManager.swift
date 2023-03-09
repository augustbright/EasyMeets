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

class UserManager: ObservableObject {
    @Published var user: User?
    @Published var userInfo: UserInfoModel?
    @Published var error: Error?;
    @Published var message: String = ""
    @Published var isLoading: Bool = false
    
    private var userInfoListeningRegistration: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
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
            self.message = "displayName: \(user?.displayName)"
            self.listenUserInfo()
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
    
    static func createUserInfo(userId: String, displayName: String, completion: @escaping ((Error?, String?) -> Void)) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userId)
        
        userRef.getDocument() {
            (document, error) in
            if document == nil || !(document!.exists) {
                db.collection("Users").document(userId).setData(UserManager.dataFromUserInfo(UserInfoModel(
                    displayName: displayName,
                    bio: "",
                    interests: [],
                    subscribers: [],
                    invitations: [],
                    eventsAttending: [],
                    eventsMaybe: [],
                    eventsStarred: [],
                    eventsOwn: [],
                    communitiesOwn: [],
                    usersSubscriptions: [],
                    communitiesSubscriptions: [],
                    usersBlackList: [],
                    communitiesBlackList: []
                ))) {
                    error in
                    if error != nil {
                        completion(error, "user info document is not created")
                    } else {
                        completion(error, "user info document is created")
                    }
                }
            } else {
                completion(nil, "Didn't create. document is nil: \(document == nil), document exists: \(document?.exists)")
            }
        }
    }
    
    static func dataFromUserInfo(_ model: UserInfoModel) -> [String: Any] {
        return [
            "displayName": model.displayName,
            "avatar": model.avatar,
            "bio": model.bio,
            "interests": model.interests,
            
            "subscribers": model.subscribers,
            "invitations": model.invitations,

            "eventsAttending": model.eventsAttending,
            "eventsMaybe": model.eventsMaybe,
            "eventsStarred": model.eventsStarred,

            "eventsOwn": model.eventsOwn,
            "communitiesOwn": model.communitiesOwn,
            
            "usersSubscriptions": model.usersSubscriptions,
            "communitiesSubscriptions": model.communitiesSubscriptions,
            
            "usersBlackList": model.usersBlackList,
            "communitiesBlackList": model.communitiesBlackList
        ]
    }
    
    static func userInfoFromData(_ data: [String: Any]) -> UserInfoModel {
        return UserInfoModel(
            displayName: data["displayName"] as! String,
            avatar: data["avatar"] as? String,
            bio: data["bio"] as! String,
            interests: data["interests"] as! [String],

            subscribers: data["subscribers"] as! [String],
            invitations: data["invitations"] as! [String],

            eventsAttending: data["eventsAttending"] as! [String],
            eventsMaybe: data["eventsMaybe"] as! [String],
            eventsStarred: data["eventsStarred"] as! [String],

            eventsOwn: data["eventsOwn"] as! [String],
            communitiesOwn: data["communitiesOwn"] as! [String],

            usersSubscriptions: data["usersSubscriptions"] as! [String],
            communitiesSubscriptions: data["communitiesSubscriptions"] as! [String],

            usersBlackList: data["usersBlackList"] as! [String],
            communitiesBlackList: data["communitiesBlackList"] as! [String]
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
    
    func ownEvent(eventId: String) {
        guard let userId = self.user?.uid else {
            return
        }
        
        let userRef = self.db.collection("Users").document(userId)
        userRef.updateData([
            "eventsOwn": FieldValue.arrayUnion([eventId])
        ])
    }
    
}
