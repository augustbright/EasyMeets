//
//  ParticipantsApp.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import FirebaseCore

@main
struct ParticipantsApp: App {
    @StateObject var userManager = UserManager()
    @StateObject var eventManager = EventManager()
    
    init() {
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
