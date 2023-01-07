//
//  LoginPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct LoginPage<Content: View>: View {
    @State var isLoginModalShown = false
    var content: () -> Content

    var body: some View {
        VStack {
            VStack(content: content)
            Button {
                isLoginModalShown = true
            } label: {
                Text("Sign in")
            }
            .padding(.vertical)
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isLoginModalShown) {
                SignInPage(isPresented: $isLoginModalShown)
            }

            Text("Don't have an account yet?")
                .font(.body)
                .foregroundColor(.secondary)
            Button(action: { }) {
                Text("Sign up")
            }
            
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage() {
            Text("Sign in to create an event")
                .font(.title)
        }
    }
}
