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
            AsyncImage(
                url: URL(string:community.image),
                            content: { image in
                                image.resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .frame(width: 160, height: 160)
                            },
                            placeholder: {
                                ProgressView()
                                    .frame(width: 160.0, height: 160.0)
                            }
            )
            VStack(alignment: .leading) {
                Text(community.name)
                    .font(.title)
                Text("Followers: \(community.followers)")
                Text(community.about)
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
    static var data = DataModel()
    static var previews: some View {
        CommunityPreview(community: data.communities[0])
    }
}
