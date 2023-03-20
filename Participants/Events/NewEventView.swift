//
//  CreateEventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import PhotosUI
import MapKit
import FirebaseStorage
import Firebase
import FormValidator
import PopupView
import ConfettiSwiftUI

struct NewEventView: View {
    @Binding var event: EventModel?

    @State private var error: Error?

    var body: some View {
        VStack(alignment: .leading) {
            EditEventView() {
                event, error in
                guard error == nil else {
                    self.error = error
                    return
                }
                self.event = event
            }

        }
        .padding(.bottom)
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateEventPage()
                .environmentObject(UserManager())
        }
    }
}
