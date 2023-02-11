//
//  WithUser.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 11.01.2023.
//

import SwiftUI
import Firebase

struct WithUser<Content: View, Message: View>: View {
    @EnvironmentObject private var userManager: UserManager
    var message: () -> Message
    var content: (User, UserInfoModel) -> Content

    var body: some View {
        VStack {
            if let error = userManager.error {
                Text(error.localizedDescription)
            }
            if userManager.isLoading || userManager.user != nil && userManager.userInfo == nil {
                ProgressView()
            } else if let user = userManager.user, let userInfo = userManager.userInfo {
                content(user, userInfo)
            } else {
                SignUpSignIn() {
                    message()
                }
            }

        }
    }
}

struct WithUser_Previews: PreviewProvider {
    static var previews: some View {
        WithUser {
            Text("You need to sign in")
        } content: {
            (user, userInfo) in
            Text("You are signed in as \(user.uid)")
        }
            .environmentObject(UserManager())
    }
}
