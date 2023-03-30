//
//  CommentsTestPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 23.03.2023.
//

import SwiftUI

struct CommentTestPage: View {
    @State private var commentText = ""
    @EnvironmentObject private var userManager: UserManager
    private let eventId = "4Y3d8QSVEFqgZgAQFbg8"

    var body: some View {
        ScrollView {
            Text("Comments Test Area")
                .font(.title)
            Divider()
                .padding()
            
            Comments(eventId: eventId)
        }
    }
}

struct CommentTestPage_Previews: PreviewProvider {
    static var previews: some View {
        CommentTestPage()
            .environmentObject(UserManager())
    }
}
