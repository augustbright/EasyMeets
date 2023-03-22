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
import GoogleSignIn

class UserManager: ObservableObject {
    @Published var user: User?
    @Published var userInfo: UserInfoModel?
    @Published var isSigningIn: Bool = false
    @Published var signInError: Error?
    
    private var userInfoListeningRegistration: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
        listen()
    }
    
    func signIn(withEmail email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        self.isSigningIn = true
        Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] (result, error) in
            guard let self = self else { return }
            self.isSigningIn = false
            
            guard error == nil else {
                self.signInError = error
                self.isSigningIn = false
                return
            }
            self.signInError = nil
            if let completion {
                completion(result, error)
            }
        }
    }
    
    func signInWithGoogle() {
        self.isSigningIn = true
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.rootViewController else {
            self.isSigningIn = false
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.isSigningIn = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController) { signInResult, error in
                guard error == nil else {
                    self.signInError = error
                    self.isSigningIn = false
                    return
                }
                guard let result = signInResult else {
                    self.isSigningIn = false
                    return
                }
                let user = result.user
                guard let idToken = user.idToken?.tokenString
                else {
                    self.isSigningIn = false
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)

                Auth.auth().signIn(with: credential) { result, error in
                    guard error == nil else {
                        self.signInError = error
                        return
                    }
                    self.isSigningIn = false
                }
            }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Couldn't sign out")
        }
    }
    
    private func listen() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
            self.userInfo = nil
            self.listenUserInfo()
        }
    }
    
    private func listenUserInfo() {
        if let userInfoListeningRegistration {
            userInfoListeningRegistration.remove()
            self.userInfoListeningRegistration = nil
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
                    eventsAttending: [],
                    eventsOwn: []
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
            "eventsAttending": model.eventsAttending,
            "eventsOwn": model.eventsOwn
        ]
    }
    
    static func userInfoFromData(_ data: [String: Any]) -> UserInfoModel {
        return UserInfoModel(
            displayName: data["displayName"] as! String,
            eventsAttending: data["eventsAttending"] as! [String],
            eventsOwn: data["eventsOwn"] as! [String]
        )
    }
    
    func attendEvent(eventId: String) {
        guard let userId = self.user?.uid else {
            return
        }
        
        let userRef = self.db.collection("Users").document(userId)
        userRef.updateData([
            "eventsAttending": FieldValue.arrayUnion([eventId]),
        ])
        
        let eventRef = self.db.collection("Events").document(eventId)
        eventRef.updateData([
            "peopleAttending": FieldValue.arrayUnion([userId]),
        ])
    }
    
    func leaveEvent(eventId: String) {
        guard let userId = self.user?.uid else {
            return
        }
        
        let userRef = self.db.collection("Users").document(userId)
        userRef.updateData([
            "eventsAttending": FieldValue.arrayRemove([eventId])
        ])
        let eventRef = self.db.collection("Events").document(eventId)
        eventRef.updateData([
            "peopleAttending": FieldValue.arrayRemove([userId]),
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
