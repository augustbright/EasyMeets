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
    @State private var didntGetEmailPresented = false

    var body: some View {
        VStack(alignment: .leading) {
            if let user = userManager.user {
                VStack() {
                    Text("Verify your email")
                        .font(.title)

                    HStack{Spacer()}
                    Text(user.email ?? "")
                        .bold()
                        .font(.title2)

                }

                VStack(alignment: .leading) {
                    Text("We've sent you a verification email on this address.")
                        .padding(.top)
                    Text("Please, __follow the link__ in the email to complete your registration.")
                }
                .foregroundColor(.secondary)

                Button("I didn't get any email") {
                    self.didntGetEmailPresented = true
                }
                    .controlSize(.small)
                    .padding(.top, 2)
                    .sheet(isPresented: $didntGetEmailPresented) {
                        DidntGetVerificationEmail(isPresented: $didntGetEmailPresented)
                    }

                Divider()
                    .padding(.top)
                
                Button("Switch account") {
                    do {
                        try Auth.auth().signOut()
                    } catch {}
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal)
    }
}

struct CompleteRegistrationModal_Previews: PreviewProvider {
    static var previews: some View {
        CompleteRegistrationModal()
            .environmentObject(UserManager())
    }
}
