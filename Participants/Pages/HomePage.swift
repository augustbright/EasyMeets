//
//  HomePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 05.04.2023.
//

import SwiftUI

struct HomePage: View {
    var isActive: Bool
    @StateObject private var plansObserver = PlansObserver()
    
    private var todayPlanned: [EventModel] {
        guard let events = plansObserver.plannedTodayEvents else {
            return []
        }
        return events
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack{Spacer()}
            
            FeedbackRequest()
                .padding()

            if todayPlanned.count == 0 {
                Text("No plans for today")
                    .foregroundColor(.secondary)
            } else {
                Text("Your Plans for Today")
                    .font(.title2)
                EventsList(events: todayPlanned)
            }

            HStack {
                NavigationLink("See All My Plans")  {
                    MyPlansPage()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding([.horizontal])
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomePage(isActive: true)
        }
        .environmentObject(UserManager())
    }
}
