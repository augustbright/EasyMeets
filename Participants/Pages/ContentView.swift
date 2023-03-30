//
//  ContentView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "meets"
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ExploreEventsPage(isActive: selectedTab == "meets")
                    .tabItem {
                        Label("Meets", systemImage: "star")
                    }
                    .tag("meets")
                MyProfilePage(isActive: selectedTab == "profile")
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
                    .tag("profile")
            }
            .tabViewStyle(DefaultTabViewStyle())
            .navigationTitle(selectedTab == "meets" ? "Easy Meets" : userManager.userInfo?.displayName ?? "My Profile")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserManager())
    }
}
