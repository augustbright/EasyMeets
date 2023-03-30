//
//  CommentsSection.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 23.03.2023.
//

import SwiftUI

struct CommentSection: View {
    var eventId: String
    var parentCommentId: String?
    @StateObject private var observer: CommentSectionObserver
    
    init(eventId: String, parentCommentId: String? = nil) {
        self.eventId = eventId
        self.parentCommentId = parentCommentId
        _observer = StateObject(wrappedValue: CommentSectionObserver(eventId: eventId, parentCommentId: parentCommentId))
    }

    var body: some View {
        VStack {
            if let comments = observer.comments, let ownerId = observer.ownerId {
                ForEach(comments, id: \.id) { comment in
                    Comment(comment: comment.model, id: comment.id, eventId: eventId, sectionOwnerId: ownerId, parentCommentId: parentCommentId)

                    if comment.id != comments.last?.id {
                       Divider()
                    }
                }
            } else if parentCommentId == nil {
                ProgressView()
                    .padding(.top)
            }
        }
    }
}

struct CommentSection_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            CommentSection(eventId: "4Y3d8QSVEFqgZgAQFbg8")
                .environmentObject(UserManager())
        }
    }
}
