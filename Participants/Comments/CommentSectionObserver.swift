//
//  CommentSectionObserver.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 23.03.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CommentSectionObserver: ObservableObject {
    @Published var ownerId: String?
    @Published var comments: Array<(id: String, model: CommentModel)>?

    private let db = Firestore.firestore()
    
    init(eventId: String, parentCommentId: String?) {
        listen(eventId, parentCommentId)
    }
    
    func listen(_ eventId: String, _ parentId: String?) {
        let collectionRef = CommentSectionObserver.getCollectionRef(eventId: eventId, parentId: parentId)
        
        collectionRef
            .order(by: "dateTimeCreated", descending: true)
            .addSnapshotListener { snapshot, error in
                guard error == nil else {
                    self.comments = nil
                    return
                }
                
                guard let snapshot else {
                    self.comments = nil
                    return
                }
                self.comments = snapshot.documents.map {
                    commentData in (
                        id: commentData.documentID,
                        model: CommentModel(data: commentData.data())
                    )
                }
            }
        
        db.collection("Events").document(eventId).addSnapshotListener { snapshot, error in
            guard error == nil else {
                self.ownerId = nil
                return
            }
            
            guard let snapshot else {
                self.ownerId = nil
                return
            }
            if let data = snapshot.data() {
                self.ownerId = data["authorId"] as! String
            } else {
                self.ownerId = nil
            }
        }
    }
    
    static func getCollectionRef(eventId: String, parentId: String?) -> CollectionReference {
        var collectionRef = Firestore.firestore()
            .collection("Events")
            .document(eventId)
            .collection("comments")
        if let parentId {
            collectionRef = collectionRef.document(parentId).collection("replies")
        }
        
        return collectionRef
    }
    
    static func post(eventId: String, parentId: String?, content: String, user: User, userInfo: UserInfoModel, completion: ((Error?) -> Void)? = nil) {
        if content.isEmpty {
            if let completion { completion(nil) }
            return
        }
        
        let collectionRef = CommentSectionObserver.getCollectionRef(eventId: eventId, parentId: parentId)
        
        collectionRef.addDocument(data: [
                "content": content,
                "authorId": user.uid,
                "authorName": userInfo.displayName,
                "dateTimeCreated": Timestamp(),
                "likes": []
            ], completion: completion)
    }
    
    static func delete(eventId: String, parentId: String?, commentId: String) {
        let collectionRef = CommentSectionObserver.getCollectionRef(eventId: eventId, parentId: parentId)
        
        collectionRef
            .document(commentId)
            .setData([
                "deleted": true
            ], merge: true)
    }
    
    static func restore(eventId: String, parentId: String?, commentId: String) {
        let collectionRef = CommentSectionObserver.getCollectionRef(eventId: eventId, parentId: parentId)

        collectionRef
            .document(commentId)
            .setData([
                "deleted": false
            ], merge: true)
    }
    
    static func like(eventId: String, parentId: String?, commentId: String, userId: String) {
        let collectionRef = CommentSectionObserver.getCollectionRef(eventId: eventId, parentId: parentId)
        
        collectionRef
            .document(commentId)
            .setData([
                "likes": FieldValue.arrayUnion([userId])
            ], merge: true)
    }
    
    static func unlike(eventId: String, parentId: String?, commentId: String, userId: String) {
        let collectionRef = CommentSectionObserver.getCollectionRef(eventId: eventId, parentId: parentId)
        
        collectionRef
            .document(commentId)
            .setData([
                "likes": FieldValue.arrayRemove([userId])
            ], merge: true)
    }
}
