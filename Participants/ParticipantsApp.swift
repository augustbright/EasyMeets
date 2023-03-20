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
        FirebaseApp.configure()
        Firestore.firestore().clearPersistence()
    }

    var body: some Scene {
        WindowGroup {
            AuthGuardPage()
                .environmentObject(userManager)
                .environmentObject(eventManager)
        }
    }
}
