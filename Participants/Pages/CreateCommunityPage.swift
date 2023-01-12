//
//  CreateCommunityPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import Firebase

struct CreateCommunityPage: View {
    @EnvironmentObject var userManager: UserManager
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a new community...").font(.title).padding(.bottom)
            Text("Community name").font(.caption)
            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
            Text("About us").font(.caption)
            TextEditor(text: $description)
                .border(.gray)
            
            HStack(spacing: 20.0) {
                Spacer()
                Button("Save draft") {}
                    .foregroundColor(.secondary)
                Button("Publish") {publish()}
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding(.top)
        }
        .padding(.horizontal)
    }
    
    func publish() {
        guard let user = userManager.user else {
            return
        }
        let db = Firestore.firestore()
        let data = CommunityManager.dataFromCommunity(CommunityModel(authorId: user.uid, name: title, description: description, followers: []))
        let newCommunityRef = db.collection("Communities").addDocument(data: data) {
            _ in
        }
    }
}

struct CreateCommunityPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateCommunityPage()
    }
}
