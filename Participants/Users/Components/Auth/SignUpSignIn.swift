//
//  LoginPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct SignUpSignIn<Content: View>: View {
    var content: () -> Content

    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject private var userManager: UserManager

    @State private var isSignUpModalShown = false

    var body: some View {
        NavigationStack() {
            VStack {
                Text("Easy Meets")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.orange)
                    .padding(.bottom, 16.0)

                if let error = userManager.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                }
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                HStack {
                    if userManager.isLoading {
                        ProgressView()
                            .frame(height: 34)
                    } else {
                        Button("Sign In") {
                            login()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Spacer()
                    Button("forgot your password?") {
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                }
                .padding(.vertical)
                
                Divider()
                    .padding(.vertical)
                NavigationLink  {
                    SignUpModal()
                } label: {
                    Text("Create a new account")
                }
            }
            .padding()
            .textFieldStyle(.roundedBorder)
        }
    }
    
    func login() {
        userManager.signIn(withEmail: email, password: password) {
            (result, error) in
            guard error == nil else {
                return
            }
            email = ""
            password = ""
        }
    }
}

struct SignUpSignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignUpSignIn() {
            Text("Sign in to create an event")
                .font(.title)
        }
        .environmentObject(UserManager())
    }
}
