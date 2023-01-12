//
//  CommunityPreview.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct CommunityPreview: View {
    var community: CommunityModel
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(community.name)
                    .font(.title)
                Text("Followers: \(community.followers.count)")
                Text(community.description)
                    .font(.body)
                    .fontWeight(.light)
                    .padding(.top)
                Spacer()
            }
            .frame(height: 160.0)
            Spacer()
        }
    }
}

struct CommunityPreview_Previews: PreviewProvider {
    static var previews: some View {
        CommunityPreview(community: CommunityModel(authorId: "", name: "Awesome community", description: "Join us! JOIN", followers: []))
    }
}
