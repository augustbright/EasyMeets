//
//  CompleteRegistrationModal.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 24.02.2023.
//

import SwiftUI
import FirebaseAuth

struct CompleteRegistrationModal: View {
    @Binding var isPresented: Bool

    var body: some View {
        WithUser {
            Text("")
        } content: { user, userInfo in
            VStack(spacing: 16.0) {
                if !user.isEmailVerified {
                    Text("We have sent you a email on __\(user.email ?? "")__")

                    Text("Please, follow the link to verify your account")

                    Button("Send again") {
                        user.sendEmailVerification() {
                            error in
                            self.isPresented = false
                        }
                    }
                }
            }
        }
    }
}

struct CompleteRegistrationModal_Previews: PreviewProvider {
    static var previews: some View {
        CompleteRegistrationModal(isPresented: .constant(true))
            .environmentObject(UserManager())
    }
}
