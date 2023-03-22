//
//  ParticipantsApp.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn

@main
struct ParticipantsApp: App {
    @StateObject private var userManager = UserManager()
    @StateObject private var eventManager = EventManager()
    
    init() {
        FirebaseApp.configure()
        Firestore.firestore().clearPersistence()
        print("debug: start!")
    }

    var body: some Scene {
        WindowGroup {
            AuthGuardPage()
                .environmentObject(userManager)
                .environmentObject(eventManager)
                .onOpenURL { url in
                  GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                  GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    //TODO: Check if `user` exists; otherwise, do something with `error`
                  }
                }
        }
    }
}
