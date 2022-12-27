//
//  ExploreCommunitiesView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct ExploreCommunitiesView: View {
    @EnvironmentObject var data: DataModel
    
    var body: some View {
            NavigationStack() {
                List(data.communities) { community in
                    NavigationLink  {
                        CommunityPage(community: community)
                    } label: {
                        CommunityPreview(community: community)
                    }
                }
                .navigationTitle("Communities")
            }
    }
}

struct ExploreCommunitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreCommunitiesView()
            .environmentObject(DataModel())
    }
}
