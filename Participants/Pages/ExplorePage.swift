//
//  ExplorePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

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

    @EnvironmentObject var data: DataModel
    @State private var category: Category = .events

    var body: some View {
        VStack {
            HStack {
                Button {
                    category = .events
                } label: {
                    Label("Events", systemImage: "party.popper")
                }
                .buttonKind(category == .events ? .prominent : .regular)
                    
                Button {
                    category = .communities
                } label: {
                    Label("Communities", systemImage: "person.3.fill")
                }
                .buttonKind(category == .communities ? .prominent : .regular)
            }
            .buttonBorderShape(.capsule)
            
            switch category {
            case .events:
                ExploreEventsView()
            case .communities:
                ExploreCommunitiesView()
            }
        }
    }
}

struct ExplorePage_Previews: PreviewProvider {
    static var previews: some View {
        ExplorePage()
            .environmentObject(DataModel())
    }
}
