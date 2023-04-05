//
//  FeedbackArea.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 02.04.2023.
//

import SwiftUI

struct FeedbackArea: View {
    private var eventId: String;
    @StateObject private var feedbacksObserver: FeedbacksObserver
    
    init(eventId: String) {
        self.eventId = eventId
        _feedbacksObserver = StateObject(wrappedValue: FeedbacksObserver(eventId: eventId))
    }

    var body: some View {
        VStack {
            HStack{Spacer()}
            if feedbacksObserver.userFeedback?.liked != true {
                Text("How was your experience?")
                    .font(.title)
                    .shadow(color: .black, radius: 2)
                Button { like() } label: {
                    Text("I Liked it ❤️")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else if (feedbacksObserver.userFeedback?.liked == true) {
                Text("I liked this event ❤️")
                    .font(.title3)
                    .shadow(color: .black, radius: 2)

            }
            Divider()
                .background(Color.white)
            HStack {
                if let positiveFeedbacks = feedbacksObserver.positiveFeedbacks, positiveFeedbacks.count > 0 {
                    VStack {
                        Text("\(positiveFeedbacks.count)")
                        Text("Positive")
                    }
                }
                
                Spacer()

                if (feedbacksObserver.userFeedback?.liked == true) {
                    Menu {
                        Button("Remove Like") {
                            unlike()
                        }
                    } label: {
                        Label("Change", systemImage: "ellipsis")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .bold()
        .padding()
        .foregroundColor(.white)
        .background(Color.green.opacity(1).gradient)
    }
    
    private func like() {
        self.feedbacksObserver.setLike(true)
    }
    
    private func unlike() {
        self.feedbacksObserver.setLike(false)
    }
}

struct FeedbackArea_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackArea(eventId: "3HDdQMelcKrh17vFWZB2")
    }
}
