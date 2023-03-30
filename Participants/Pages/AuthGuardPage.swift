//
//  AuthGuardPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 17.03.2023.
//

import SwiftUI


struct AuthGuardPage: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var debug = "debug";
    var body: some View {
        VStack {
            if userManager.isSigningIn || userManager.user != nil && userManager.hasUserInfo == nil {
                HStack {
                    Spacer()
                    ProgressView("Signing In")
                    Spacer()
                }
            } else if let user = userManager.user, user.isEmailVerified, let userInfo = userManager.userInfo {
                ContentView()
            } else if let user = userManager.user, !user.isEmailVerified {
                CompleteRegistrationModal()
            } else if userManager.hasUserInfo == false {
                SignUpIntroduce()
            } else {
                WelcomePage()
            }
        }
    }
}

struct AuthGuardPage_Previews: PreviewProvider {
    static var previews: some View {
        AuthGuardPage()
            .environmentObject(UserManager())
    }
}
