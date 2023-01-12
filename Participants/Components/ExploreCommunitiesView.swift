//
//  ExploreCommunitiesView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI
import Firebase

struct ExploreCommunitiesView: View {
    @State private var communities: [CommunityModel]?
    
    var body: some View {
        NavigationStack() {
            VStack {
                NavigationLink {
                    CreateCommunityPage()
                } label: {
                    Label("Create new community", systemImage: "plus")
                }
                if let communities = communities {
                    List(communities) { community in
                        NavigationLink  {
                            CommunityPage(communityId: community.id!)
                        } label: {
                            CommunityPreview(community: community)
                        }
                    }
                }
            }
            .navigationTitle("Communities")
        }
        .onAppear() {
            fetchCommunities()
        }
    }
    
    func fetchCommunities() {
        let db = Firestore.firestore()
        let collection = db.collection("Communities")
        collection.addSnapshotListener() {
            (querySnapshot, error) in
            guard error == nil else {
                return
            }
            self.communities = querySnapshot!.documents.map() {
                document in CommunityManager.communityFromData(document.data(), document.documentID)
            }
        }
    }
}

struct ExploreCommunitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreCommunitiesView()
            .environmentObject(UserManager())
    }
}
