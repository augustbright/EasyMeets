//
//  ExplorePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase

enum ButtonKind {
    case regular, prominent
}

extension Button {
    @ViewBuilder
    func buttonKind(_ kind: ButtonKind) -> some View {
        switch kind {
        case .prominent:
            buttonStyle(.borderedProminent)
        case .regular:
            buttonStyle(.bordered)
        }
    }
}


struct ExplorePage: View {
    enum Category {
        case events, communities
    }
    
    @State private var category: Category = .events
    
    var body: some View {
        NavigationStack {
            List () {
                NavigationLink("Events") {
                    ExploreEventsPage()
                }
                NavigationLink("Communities") {
                    ExploreCommunitiesView()
                }
            }
            .navigationTitle("Explore")
        }
    }    
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
            .environmentObject(UserManager())
    }
}
