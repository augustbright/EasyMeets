//
//  EventControlsView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 10.01.2023.
//

import SwiftUI
import Firebase

struct EventControlsView: View {
    var eventId: String
    var onEdit: () -> Void

    @EnvironmentObject private var userManager: UserManager
    
    private var isOwner: Bool? {
        guard let userInfo = userManager.userInfo else {
            return nil
        }
        return userInfo.eventsOwn.contains(eventId)
    }
    
    var body: some View {
        VStack {
            if let userInfo = userManager.userInfo {
                HStack {
                    if isOwner == true {
                        Spacer()
                        Button("Edit") {
                            onEdit()
                        }
                    } else if (userInfo.eventsAttending.contains(eventId)) {
                        attending
                    } else {
                        Button("I'm in!") {
                            userManager.attendEvent(eventId: eventId)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
    var attending: some View {
        Menu {
            Button("I'm not attending", role: .destructive) {
                userManager.leaveEvent(eventId: eventId)
            }
        } label: {
            Text("Attending")
                .bold()
                .foregroundColor(.green)
        }
        .buttonStyle(.borderless)
    }
}

struct EventControlsView_Previews: PreviewProvider {
    static var previews: some View {
        EventControlsView(eventId: "J4fs1BWJYdrdjuuYlDf2") {}
            .environmentObject(UserManager())
    }
}
