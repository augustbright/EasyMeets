//
//  AuthGuardPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 17.03.2023.
//

import SwiftUI

struct AuthGuardPage: View {
    @EnvironmentObject private var userManager: UserManager
    var body: some View {
        VStack {
            if let user = userManager.user, user.isEmailVerified {
                ContentView()
            } else if let user = userManager.user, !user.isEmailVerified {
                CompleteRegistrationModal()
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
