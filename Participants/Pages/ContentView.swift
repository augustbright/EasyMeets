//
//  ContentView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct ContentView: View {
    enum TabId {
        case home, explore, profile
    }
    @State private var selectedTab: TabId = .home
    @EnvironmentObject private var userManager: UserManager
    
    var navigationTitle: String {
        switch self.selectedTab {
        case .home:
            return "Easy Meets"
        case .explore:
            return "Explore"
        case .profile:
            return self.userManager.userInfo?.displayName ?? "My Profile"
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomePage(isActive: selectedTab == .home)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(TabId.home)
                ExploreEventsPage(isActive: selectedTab == .explore)
                    .tabItem {
                        Label("Explore", systemImage: "star")
                    }
                    .tag(TabId.explore)
                MyProfilePage(isActive: selectedTab == .profile)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
                    .tag(TabId.profile)
            }
            .tabViewStyle(DefaultTabViewStyle())
            .navigationTitle(self.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserManager())
    }
}
