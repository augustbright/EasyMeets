//
//  CreateCommunityPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct CreateCommunityPage: View {
    @EnvironmentObject var data: DataModel
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
        var communityId = data.communities.last?.id ?? 0 + 1
    
        data.communities.append(CommunityModel(id: communityId, name: title, about: description, followers: 0, image: "", isFollowed: false))
    }
}

struct CreateCommunityPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateCommunityPage()
            .environmentObject(DataModel())
    }
}
