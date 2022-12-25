//
//  ExplorePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct ExplorePage: View {
    @EnvironmentObject var data: DataModel

    var body: some View {
            NavigationStack() {
                NavigationLink {
                    CreateEventPage()
                } label: {
                    Label("Create event", systemImage: "plus.app")
                }
                    List(data.eventPreviews) { eventPreview in
                        NavigationLink  {
                            EventPage(event: eventPreview)
                        } label: {
                            EventPreview(eventPreview: eventPreview)
                        }
                    }
        
                .navigationTitle("Explore")
            }
        
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
            .environmentObject(DataModel())
    }
}
