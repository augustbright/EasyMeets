//
//  EventControls.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct EventControls: View {
    @EnvironmentObject var data: DataModel
    var eventId: Int;
    var eventIdx: Int {
        data.eventPreviews.firstIndex(where: {
            event in event.id == eventId
        })!
    }
    var event: EventPreviewData {
        data.eventPreviews[eventIdx]
    }
    
    var change: some View {
        Menu("Change") {
            Button(role: .destructive) {
                data.eventPreviews[eventIdx].isThinking = false
                data.eventPreviews[eventIdx].isAttending = false
            } label: {
                Label("I'm out", systemImage: "xmark.circle")
            }
            
            if !(event.isThinking ?? false) {
                Button("I'll think...") {
                    data.eventPreviews[eventIdx].isThinking = true
                    data.eventPreviews[eventIdx].isAttending = false
                }
            }
            
            if !(event.isAttending ?? false) {
                Button("I'm in") {
                    data.eventPreviews[eventIdx].isThinking = false
                    data.eventPreviews[eventIdx].isAttending = true
                }
            }


        }
        .buttonStyle(.bordered)
        .foregroundColor(.gray)
    }

    var body: some View {
        HStack(spacing: 20.0) {
            if event.isAttending ?? false {
                Text("You are participating")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                change
            } else if event.isThinking ?? false {
                Text("You might participate")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                change
            } else {
                Button("I'm in (\(event.peopleAttending))", action: {
                    data.eventPreviews[eventIdx].isAttending = true
                })
                    .buttonStyle(.borderedProminent)
                Button("Maybe (\(event.peopleThinking))", action: {
                    data.eventPreviews[eventIdx].isThinking = true
                    data.eventPreviews[eventIdx].isAttending = false
                })
            }
            Spacer()
            Button {
                data.eventPreviews[eventIdx].isFavorite.toggle()
                
            } label: {
                Label("Toggle favorite", systemImage:  event.isFavorite ? "star.fill" : "star").labelStyle(.iconOnly)
                    .foregroundColor(event.isFavorite ? .yellow : .gray)
            }
        }
    }
}

struct EventControls_Previews: PreviewProvider {
    static var data = DataModel()
    static var previews: some View {
        EventControls(eventId: data.eventPreviews[0].id)
            .environmentObject(data)
    }
}
