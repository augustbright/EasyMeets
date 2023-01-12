//
//  HomePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    NavigationLink {
                        CreateEventPage()
                    } label: {
                        Label("Create event", systemImage: "plus.app")
                    }
                    Spacer()
                }
                Section("Your upcoming events") {
                    UpcomingEventsView()
                }
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(UserManager())
    }
}
