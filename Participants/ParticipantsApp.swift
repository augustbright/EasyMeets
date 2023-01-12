//
//  ParticipantsApp.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct ParticipantsApp: App {
    @StateObject var locationManager = LocationManager()
    @StateObject var userManager = UserManager()
    @StateObject var eventManager = EventManager()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(userManager)
                .environmentObject(eventManager)
        }
    }
}
