//
//  LoginPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI
import Firebase

struct LoginPage: View {
    @State var email = ""
    @State var password = ""
    @State var errorMessage: String?;
    @State var currentUser = Auth.auth().currentUser

    var body: some View {
        VStack {
            if let errorMessage {
                Text("Couldn't sign in: \(errorMessage)").foregroundColor(.red)
            }
            if let currentUser {
                Text(currentUser.uid)
            } else {
                Text("No user")
            }
            
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button(action: { login() }) {
                Text("Sign in")
            }
            Button(action: { logout() }) {
                Text("Sign out")
            }

            .padding()
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                self.errorMessage = error?.localizedDescription;
                return;
            }
            
            currentUser = result?.user
            self.errorMessage = nil
        }
    }
        
        func logout() {
            do {
                try Auth.auth().signOut()
            } catch {}
            
            currentUser = nil
        }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
