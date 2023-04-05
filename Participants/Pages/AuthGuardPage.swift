//
//  AuthGuardPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 17.03.2023.
//

import SwiftUI
import FirebaseAuth

struct AuthGuardPage: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var viewState = UUID()
    
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if let user = userManager.user, !user.isEmailVerified {
                userManager.reload()
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
