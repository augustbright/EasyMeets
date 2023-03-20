//
//  ExplorePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase

struct ExplorePage: View {
    var body: some View {
        NavigationStack {
            ExploreEventsPage()
        }
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
            .environmentObject(UserManager())
    }
}
