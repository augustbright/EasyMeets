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

@main
struct ParticipantsApp: App {
    @StateObject var userManager = UserManager()
    @StateObject var eventManager = EventManager()
    
    init() {
//        let settings = Firestore.firestore().settings
//        settings.host = "localhost:8080"
//        settings.isPersistenceEnabled = false
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
//
//        Auth.auth().useEmulator(withHost:"localhost", port:9099)
//        Storage.storage().useEmulator(withHost:"localhost", port:9199)

        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .environmentObject(eventManager)
        }
    }
}
