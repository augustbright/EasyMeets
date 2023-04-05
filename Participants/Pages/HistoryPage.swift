//
//  HistoryPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 31.03.2023.
//

import SwiftUI

struct HistoryPage: View {
    @StateObject private var plansObserver = PlansObserver()
    @EnvironmentObject private var userManager: UserManager

    private var pastEvents: [EventModel] {
        guard let events = plansObserver.passedEvents else {
            return []
        }
        return events
    }

    var body: some View {
        VStack(alignment: .leading) {
            // A place for fixed header/filter
            
            ScrollView {
                VStack(alignment: .leading) {
                    HStack{Spacer()}

                    if pastEvents.count == 0 {
                        Text("You have not participated in anything yet")
                            .foregroundColor(.secondary)
                    } else {
                        EventsList(events: pastEvents)
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("History")
        .onAppear() {
            self.plansObserver.setUserInfo(userManager.userInfo, userManager.user)
        }
        .onChange(of: userManager.userInfo) {
            userInfo in
            self.plansObserver.setUserInfo(userManager.userInfo, userManager.user)
        }
    }
}

struct HistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryPage()
                .environmentObject(UserManager())
        }
    }
}
