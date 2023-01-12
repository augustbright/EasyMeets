//
//  ContentView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                HomePage()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                ExplorePage()
                    .tabItem {
                        Label("Explore", systemImage: "star")
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
