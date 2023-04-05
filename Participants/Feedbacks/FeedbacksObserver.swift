//
//  FeedbacksObserver.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 02.04.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FeedbacksObserver: ObservableObject {
    @Published var feedbacks: [FeedbackModel]?
    @Published var userFeedback: FeedbackModel?
    @Published var positiveFeedbacks: [FeedbackModel]?
    
    init (eventId: String) {
        self.eventId = eventId
        self.listen()
    }
    
    func setLike(_ like: Bool) {
        guard
            let userInfo = self.userManager.userInfo,
            let user = self.userManager.user
        else {
            return
        }

        Firestore.firestore()
            .collection("Events")
            .document(self.eventId)
            .collection("feedbacks")
            .document(user.uid)
            .setData([
                "authorId": user.uid,
                "authorName": userInfo.displayName,
                "createdAt": Timestamp(),
                "eventId": self.eventId,
                "liked": like,
            ], merge: true)
    }
    
    private let userManager = UserManager()
    private var eventId: String
    
    private func listen() {
        Firestore.firestore().collection("Events").document(self.eventId).collection("feedbacks")
            .addSnapshotListener { collectionSnapshot, error in
                guard error == nil else {
                    self.setFeedbacks(nil)
                    return
                }
                guard let collectionSnapshot else {
                    self.setFeedbacks(nil)
                    return
                }

                let feedbacks = collectionSnapshot.documents.map { documentSnapshot in
                    let data = documentSnapshot.data()
                    return createFeedbackModelFromData(data)
                }
                
                self.setFeedbacks(feedbacks)
            }
    }
    
    private func setFeedbacks(_ feedbacks: [FeedbackModel]?) {
        self.feedbacks = feedbacks
        guard feedbacks != nil else {
            self.userFeedback = nil
            self.positiveFeedbacks = nil
            return
        }
        
        let userId = Auth.auth().currentUser?.uid ?? nil
        self.userFeedback = feedbacks?.first { feedback in feedback.authorId == userId }
        self.positiveFeedbacks = feedbacks?.filter { $0.liked == true }
    }
}
