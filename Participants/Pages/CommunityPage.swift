//
//  CommunityPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct CommunityPage: View {
    var communityId: String
    @State private var error: Error?
    @State private var community: CommunityModel?
    @State private var imageUrl: URL?
    @State private var events: [EventModel] = []
    
    
    var body: some View {
        List {
            if let community = community {
                if let imageUrl = imageUrl {
                    AsyncImage(
                        url: imageUrl,
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFill()
                        },
                        placeholder: {
                            ProgressView()
                                .frame(width: 160.0, height: 160.0)
                        }
                    )
                }
                Section {
                    HStack(alignment: .top) {
                        Text(community.name)
                            .font(.largeTitle)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Button("Follow") {}
                                .buttonStyle(.borderedProminent)
                            Text("Followers: \(community.followers.count)")
                        }
                    }
                }
                Section("About this community") {
                    Text(community.description)
                        .font(.body)
                        .fontWeight(.light)
                        .padding(.top)
                        .padding(.horizontal)
                }
                
            }
            Section("Events") {
                ForEach(events) { event in
                    NavigationLink  {
                        EventPage(eventId: event.id!)
                    } label: {
                        EventPreview(eventPreview: event)
                    }
                }
            }
        }
        .navigationTitle("Community")
        .onAppear() {
            fetchCommunity()
            fetchEvents()
        }
    }
    
    func fetchEvents() {
        let db = Firestore.firestore()
        let collection = db.collection("Events")
        
        collection.whereField("communityId", isEqualTo: communityId).addSnapshotListener() {
            (querySnapshot, error) in
            guard error == nil else {
                return
            }
            self.events = querySnapshot!.documents.map() {
                document in EventManager.eventFromData(document.data(), document.documentID)
            }
        }
    }
    
    func fetchCommunity() {
        let db = Firestore.firestore()
        let communityRef = db.collection("Communities").document(communityId)
        communityRef.getDocument() {
            (document, error) in
            guard error == nil else {
                self.error = error
                return
            }
            if let document, document.exists, let data = document.data() {
                self.community = CommunityManager.communityFromData(data, document.documentID)
                
                if let image = community?.image {
                    let storageRef = Storage.storage().reference()
                    let imageRef = storageRef.child(image)
                    
                    imageRef.downloadURL() {
                        (url, error) in
                        guard error == nil else {
                            return
                        }
                        
                        self.imageUrl = url
                    }
                }
            }
        }
    }
}

struct CommunityPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CommunityPage(communityId: "09PrhMEmZ4eFmGEeY2D1")
                .environmentObject(UserManager())
        }
    }
}
