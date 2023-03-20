//
//  ContentView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var completeRegistrationPresented = false
    @EnvironmentObject private var userManager: UserManager

    var body: some View {        
        TabView {
            ExplorePage()
                .tabItem {
                    Label("Meets", systemImage: "star")
                }
            MyProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }.tabViewStyle(DefaultTabViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserManager())
    }
}
