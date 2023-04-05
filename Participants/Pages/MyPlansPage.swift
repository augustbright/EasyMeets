//
//  MyPlansPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.03.2023.
//

import SwiftUI

struct MyPlansPage: View {
    @StateObject private var plansObserver = PlansObserver()
    @EnvironmentObject private var userManager: UserManager
    
    private var todayPlanned: [EventModel] {
        guard let events = plansObserver.plannedTodayEvents else {
            return []
        }
        return events
    }

    private var tomorrowPlanned: [EventModel] {
        guard let events = plansObserver.plannedTomorrowEvents else {
            return []
        }
        return events
    }

    private var futurePlanned: [EventModel] {
        guard let events = plansObserver.restPlannedEvents else {
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
                    Text("Today")
                        .font(.title2)
                        
                    if todayPlanned.count == 0 {
                            Text("No Plans")
                                .foregroundColor(.secondary)
                    } else {
                        EventsList(events: todayPlanned)
                    }
                    
                    Text("Tomorrow")
                        .font(.title2)
                        .padding(.top)
                    if tomorrowPlanned.count == 0 {
                        Text("No Plans")
                            .foregroundColor(.secondary)
                    } else {
                        EventsList(events: tomorrowPlanned)
                    }

                    Text("Future")
                        .font(.title2)
                        .padding(.top)
                    if futurePlanned.count == 0 {
                        Text("No Plans")
                            .foregroundColor(.secondary)
                    } else {
                        EventsList(events: futurePlanned)
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle("My Plans")
        .onAppear() {
            self.plansObserver.setUserInfo(userManager.userInfo, userManager.user)
        }
        .onChange(of: userManager.userInfo) {
            userInfo in
            self.plansObserver.setUserInfo(userManager.userInfo, userManager.user)
        }
    }
}

struct MyPlansPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyPlansPage()
        }
        .environmentObject(UserManager())
    }
}
