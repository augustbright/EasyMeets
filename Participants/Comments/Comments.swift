//
//  Comments.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.03.2023.
//

import SwiftUI

struct Comments: View {
    var eventId: String
    
    @State private var commentText = ""
    @EnvironmentObject private var userManager: UserManager

    var body: some View {
        ScrollView {
            HStack {
                TextField("Type your reply here", text: $commentText)
                Button("Post") { post() }
                    .buttonStyle(.bordered)
            }
            .padding()
            .border(.gray)
            .padding(.bottom)

            CommentSection(eventId: eventId)
        }
    }
    
    func post() {
        let backup = commentText
        if let user = userManager.user, let userInfo = userManager.userInfo {
            commentText = ""
            CommentSectionObserver.post(eventId: eventId, parentId: nil, content: backup, user: user, userInfo: userInfo) { error in
                guard error == nil else {
                    commentText = backup
                    return
                }
            }
        }
    }

}

struct Comments_Previews: PreviewProvider {
    static var previews: some View {
        Comments(eventId: "testSection")
            .environmentObject(UserManager())
    }
}
