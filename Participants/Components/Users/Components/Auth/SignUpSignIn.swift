//
//  LoginPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct SignUpSignIn<Content: View>: View {
    @State var isLoginModalShown = false
    @State var isSignUpModalShown = false
    var content: () -> Content

    var body: some View {
        VStack {
            HStack {
                Spacer()
            }
            VStack(content: content)
            Button {
                isLoginModalShown = true
            } label: {
                Text("Sign in")
            }
            .padding(.vertical)
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isLoginModalShown) {
                SignInModal(isPresented: $isLoginModalShown)
            }

            Text("Don't have an account yet?")
                .font(.body)
                .foregroundColor(.secondary)
            Button(action: {
                isSignUpModalShown = true
            }) {
                Text("Sign up")
            }
            .sheet(isPresented: $isSignUpModalShown) {
                SignUpModal(isPresented: $isSignUpModalShown)
            }

        }
    }
}

struct SignUpSignIn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpSignIn() {
                Text("Sign in to create an event")
                    .font(.title)
            }
        }
        .environmentObject(UserManager())
    }
}
