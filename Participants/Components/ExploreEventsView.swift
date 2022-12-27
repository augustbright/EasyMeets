//
//  ExploreEventsView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct ExploreEventsView: View {
    @EnvironmentObject var data: DataModel
    @State private var searchText = ""
    @State private var filterFavorite = false
    var filterAttending: Bool?
    
    var filteredEvents: [EventPreviewData] {
        data.eventPreviews
            .filter {
                event in
                guard let filterAttending else {
                    return true
                }
                guard let isAttendingEvent = event.isAttending else {
                    return false
                }
                return isAttendingEvent == filterAttending
            }
            .filter {
                event in event.isFavorite == filterFavorite
            }
            .filter {
                event in searchText == "" || event.title.contains(searchText)
            }
    }
    
    var body: some View {
        NavigationStack() {
            List(filteredEvents) { eventPreview in
                NavigationLink  {
                    EventPage(event: eventPreview)
                } label: {
                    EventPreview(eventPreview: eventPreview)
                }
            }
            .navigationTitle(filterFavorite ? "Events (saved)" : "Events")
            .toolbar {
                ToolbarItem {
                    FavoriteButton(isSet: $filterFavorite)
                }
            }
            .searchable(text: $searchText)
        }
    }
    
}

struct ExploreEventsView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreEventsView()
            .environmentObject(DataModel())
    }
}
