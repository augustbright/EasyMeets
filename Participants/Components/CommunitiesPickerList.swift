//
//  CommunitiesPickerList.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 09.01.2023.
//

import SwiftUI
import Firebase

struct CommunitiesPickerList: View {
    @EnvironmentObject var userManager: UserManager
    @State private var communities: [CommunityModel]?
    @Binding var community: CommunityModel?
    @Binding var isShown: Bool
    
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
                        Button(community.name) {
                            self.community = community
                            self.isShown = false
                        }
                    }
                }
            }
            .navigationTitle("Communities")
        }
        .onAppear() {
            fetchOwnCommunities()
        }
    }
    
    private func fetchOwnCommunities() {
        guard let user = userManager.user else {
            return
        }
        let db = Firestore.firestore()
        db.collection("Communities")
            .whereField("authorId", isEqualTo: user.uid)
            .addSnapshotListener() {
                (snapshot, error) in
                guard error == nil, snapshot != nil else {
                    return
                }
                self.communities = snapshot!.documents.map() {
                    document in CommunityManager.communityFromData(document.data(), document.documentID)
                }
            }
    }

}

struct CommunitiesPickerList_Previews: PreviewProvider {
    static var previews: some View {
        CommunitiesPickerList(community: .constant(nil), isShown: .constant(true))
            .environmentObject(UserManager())
    }
}
