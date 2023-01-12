//
//  MyProfilePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import FirebaseAuth

struct MyProfilePage: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack { 
            if let currentUser = userManager.user {
                if let email = currentUser.email {
                    Text(email)
                }
                Button("Sign out") {
                    logout()
                }
                .buttonStyle(.bordered)
            } else {
                LoginPage() {
                    Text("Sign in to see your profile here")
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
        }
    }
}

struct MyProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        MyProfilePage()
            .environmentObject(UserManager())
    }
}
