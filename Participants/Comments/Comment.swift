//
//  Comment.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 23.03.2023.
//

import SwiftUI
import FirebaseFirestore

struct Comment: View {
    var comment: CommentModel
    var id: String
    var eventId: String
    var sectionOwnerId: String
    var parentCommentId: String?
    
    @EnvironmentObject private var userManager: UserManager
    @State private var editing = false
    @State private var commentContent = ""
    @State private var replying = false
    @State private var replyContent = ""
    var isRoot: Bool { parentCommentId == nil }

    private var isLiked: Bool {
        guard let userId = userManager.user?.uid else { return false }
        return comment.likes.contains(userId)
    }
    
    var allowEdit: Bool {
        if let user = userManager.user {
            return user.uid == comment.authorId
        } else { return false }
    }
    
    var allowDelete: Bool {
        if let user = userManager.user {
            return user.uid == comment.authorId || user.uid == sectionOwnerId
        } else { return false }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if comment.deleted == true {
                deleted
            } else {
                commentBody
            }
            if (isRoot) {
                VStack {
                    if (replying) {
                        replyView
                    }
                    CommentSection(eventId: eventId, parentCommentId: id)

                }
                .padding(.leading, 16)
                .border(width: 1, edges: [.leading], color: Color.gray)
                .padding(.leading, 16)
            }
        }
        .onAppear() {
            commentContent = comment.content
        }
    }
    
    var deleted: some View {
        HStack {
            Text("Comment is deleted")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Button("Restore") { restore() }
                .controlSize(.small)
        }
    }
    
    var commentBody: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.authorName)
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 1.0)

                Text(comment.timeCreated)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if editing {
                contentEdit
                footerEdit
            } else {
                contentView
                footerView
            }
        }
    }
    
    var contentView: some View {
        Text(comment.content)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 4.0)
            .padding(.leading, 8.0)
    }
    
    var contentEdit: some View {
        TextField("Type your reply here", text: $commentContent, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
    }
    
    var footerView: some View {
        HStack {
            Spacer()
            Button { like() } label: {
                Label(String(comment.likes.count), systemImage: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .labelStyle(.titleAndIcon)
            }
            .controlSize(.small)
            if (isRoot) {
                Divider()
                Button { self.replying = true } label: {
                    Label("Reply", systemImage: "arrowshape.turn.up.left")
                        .labelStyle(.titleAndIcon)
                }
                .controlSize(.small)
            }
            if allowEdit || allowDelete {
                Divider()
                Menu {
                    if allowEdit {
                        Button("Edit") { editing = true }
                    }
                    if allowDelete {
                        Button("Delete") { delete() }
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                }
                .controlSize(.small)
            }
            
        }
    }
    
    var footerEdit: some View {
        HStack {
            Spacer()
            Button("Cancel") {
                self.commentContent = comment.content
                editing = false
            }
            .controlSize(.small)
            Divider()
            Button("Save") { save() }
                .controlSize(.small)
                .buttonStyle(.borderedProminent)
        }
    }
    
    var replyView: some View {
        HStack {
            TextField("Type your reply here", text: $replyContent)
            Button("Cancel") {
                self.replying = false
                replyContent = ""
            }
            Button("Post") { reply() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .border(.gray)
        .padding(.bottom)
    }
    
    func delete() {
        CommentSectionObserver.delete(eventId: eventId, parentId: parentCommentId, commentId: id)
    }
    
    func restore() {
        CommentSectionObserver.restore(eventId: eventId, parentId: parentCommentId, commentId: id)
    }
    
    func save() {
        if (commentContent.isEmpty) { return }
        
        var collectionRef = CommentSectionObserver.getCollectionRef(eventId: eventId, parentId: parentCommentId)
        
        collectionRef.document(id).setData([
                "content": commentContent,
                "dateTimeEdited": Timestamp(),
            ], merge: true) { error in editing = false }
    }
    
    func like() {
        if isLiked {
            CommentSectionObserver.unlike(eventId: eventId, parentId: parentCommentId, commentId: id, userId: userManager.user!.uid)
        } else {
            CommentSectionObserver.like(eventId: eventId, parentId: parentCommentId, commentId: id, userId: userManager.user!.uid)
        }
    }
    
    func reply() {
        self.replying = false
        let backup = replyContent
        replyContent = ""

        CommentSectionObserver.post(eventId: eventId, parentId: id, content: backup, user: userManager.user!, userInfo: userManager.userInfo!) {error in
            guard error == nil else {
                replyContent = backup
                self.replying = true
                return
            }
        }
    }
}

struct Comment_Previews: PreviewProvider {
    static var previews: some View {
        Comment(comment: CommentModel.mock, id: "Dg5FNbwNBi5Np2t4QIJu", eventId: "4Y3d8QSVEFqgZgAQFbg8", sectionOwnerId: "4bR1KOGJF0Vbm2uck2ibQUEfJBz1", parentCommentId: nil)
            .environmentObject(UserManager())
            .frame(height: 100)
    }
}
