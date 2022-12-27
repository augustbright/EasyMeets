//
//  CommunityPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct CommunityPage: View {
    var community: CommunityModel
    var body: some View {
        ScrollView {
            AsyncImage(
                url: URL(string:community.image),
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
            VStack {
                HStack(alignment: .top) {
                    Text(community.name)
                        .font(.largeTitle)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Button("Follow") {}
                            .buttonStyle(.borderedProminent)
                        Text("Followers: \(community.followers)")

                    }
                }
                Text(community.about)
                    .font(.body)
                    .fontWeight(.light)
                    .padding(.top)
            }
            .padding(.horizontal)
        }
    }
}

struct CommunityPage_Previews: PreviewProvider {
    static var data = DataModel()
    static var previews: some View {
        CommunityPage(community: data.communities[0])
    }
}
