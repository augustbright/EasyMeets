//
//  CompleteRegistrationModal.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 24.02.2023.
//

import SwiftUI
import FirebaseAuth

struct CompleteRegistrationModal: View {
    @EnvironmentObject private var userManager: UserManager

    var body: some View {
        VStack(spacing: 16.0) {
            if let user = userManager.user {
                Text("We have sent you a email on __\(user.email ?? "")__")

                Text("Please, follow the link to verify your account")

                Button("Log out") {
                    do {
                        try Auth.auth().signOut()
                    } catch {}
                }
            }
        }
    }
}

struct CompleteRegistrationModal_Previews: PreviewProvider {
    static var previews: some View {
        CompleteRegistrationModal()
            .environmentObject(UserManager())
    }
}
