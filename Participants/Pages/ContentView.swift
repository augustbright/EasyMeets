//
//  ContentView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var completeRegistrationPresented = false

    var body: some View {
        VStack {
            WithUser {
                Text("")
            } content: {
                user, _ in
                VStack {
                    if !user.isEmailVerified {
                        Button("Complete your registration") {
                            completeRegistrationPresented = true
                        }
                            .buttonStyle(.borderless)
                    }
                }
            }
            .sheet(isPresented: $completeRegistrationPresented) {
                CompleteRegistrationModal(isPresented: $completeRegistrationPresented)
            }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserManager())
    }
}
