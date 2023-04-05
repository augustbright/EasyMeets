//
//  FeedbackRequest.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.03.2023.
//

import SwiftUI
import FirebaseFirestore

struct FeedbackRequest: View {
    @StateObject private var plansObserver = PlansObserver()
    @EnvironmentObject private var userManager: UserManager
    @State private var hidden = false
    @State private var skipped = false
    @State private var liked = false    
    
    var body: some View {
        VStack {
            if hidden || plansObserver.eventForFeedback == nil {
            } else if skipped {
                
            } else if liked {
                likedView
            } else {
                feedbackView
            }
        }
        .onAppear() {
            self.plansObserver.setUserInfo(userManager.userInfo, userManager.user)
        }
        .onChange(of: userManager.userInfo) {
            userInfo in
            self.plansObserver.setUserInfo(userInfo, userManager.user)
        }
    }
    
    var feedbackView: some View {
        VStack {
            if let eventForFeedback = plansObserver.eventForFeedback {
                VStack {
                    Text("How was your experience?")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    EventPreview(eventPreview: eventForFeedback)
                    
                    HStack {
                        Button { skip(event: eventForFeedback) } label: {
                            Text("Skip")
                                .frame(maxWidth: .infinity)
                        }
                        .controlSize(.large)
                        .buttonStyle(.bordered)
                        .foregroundColor(.white)
                        Button { like(event: eventForFeedback) } label: {
                            Text("Enjoyed ❤️")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.green)
                        .controlSize(.large)
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cyan.gradient)
                }
            }
        }
    }
    
    var likedView: some View {
        VStack {
            Text("❤️")
                .font(.largeTitle)
        }
    }
    
    func skip(event: EventModel) {
        setFeedback(eventId: event.id!, userId: userManager.user!.uid, data: createFeedbackData(userInfo: userManager.userInfo!, user: userManager.user!)
        )
        
        withAnimation {
            self.skipped = true
        }
    }
    
    func like(event: EventModel) {
        setFeedback(
            eventId: event.id!,
            userId: userManager.user!.uid,
            data: withLiked(
                createFeedbackData(userInfo: userManager.userInfo!, user: userManager.user!)
            )
        )
        
        withAnimation {
            self.liked = true
        }
    }
    
    func delayHide() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.hidden = true
    }
}

struct FeedbackRequest_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackRequest()
            .environmentObject(UserManager())
    }
}
