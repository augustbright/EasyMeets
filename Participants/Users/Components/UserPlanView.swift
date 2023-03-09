//
//  UserPlanView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 15.01.2023.
//

import SwiftUI

struct UserPlanView: View {
    var body: some View {
        List {
            Section {
                EventPreview(eventPreview: EventModel.mock)
                EventPreview(eventPreview: EventModel.mock)
            } header: {
                Text("Today")
            }
            
            Section {
                EventPreview(eventPreview: EventModel.mock)
            } header: {
                Text("Tomorrow")
            }

            Section {
                EventPreview(eventPreview: EventModel.mock)
            } header: {
                Text("On this week")
            }
        }
    }
}

struct UserPlanView_Previews: PreviewProvider {
    static var previews: some View {
        UserPlanView()
    }
}
