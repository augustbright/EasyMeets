//
//  DidntGetVerificationEmail.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 05.04.2023.
//

import SwiftUI
import FirebaseAuth

struct DidntGetVerificationEmail: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var userManager: UserManager
    @State private var error: Error?
    @State private var isSent = false
    @State private var isSending = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if isSent == false {
                resendView
            } else {
                sentView
            }
            
            Divider()
                .padding(.top)
            
            Text("If you continue to experience issues, please contact our support team for further assistance.")
                .padding(.top, 4)
                .foregroundColor(.secondary)
            Button("Contact our support") {}
                .padding(.top, 1)
                .controlSize(.small)
        }
        .padding(.horizontal)
    }
    
    var resendView: some View {
        VStack(alignment: .leading) {
            Text("Did not receive the verification email?")
                .font(.title)
            Text("\u{2022} Please check your __spam folder__ or any other email filters you may have set up.")
                .padding(.top, 2)
                Text("\u{2022} If it's not there, you can try resending the email")
                .padding(.top, 2)
            HStack {
                Button("Resend the Email") {
                    guard self.isSending == false else {
                        return
                    }
                    self.isSending = true
                    Auth.auth().currentUser?.sendEmailVerification() {error in
                        self.isSending = false
                        guard error == nil else {
                            self.error = error
                            return
                        }
                        self.error = nil
                        self.isSent = true
                    }
                }
                    .buttonStyle(.bordered)
                if self.isSending == true {
                    ProgressView()
                        .padding(.leading, 4)
                }
            }
            
            if let error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
    }
    
    var sentView: some View {
        VStack(alignment: .leading) {
            if let user = userManager.user {
                Text("Done!")
                    .font(.title)

                Text("A new verification email has been sent to")
                    .padding(.top, 2)
                Text("_\(user.email ?? "")_")
            }
            
        }
    }
}

struct DidntGetVerificationEmail_Previews: PreviewProvider {
    static var previews: some View {
        DidntGetVerificationEmail(isPresented: .constant(true))
            .environmentObject(UserManager())
    }
}
