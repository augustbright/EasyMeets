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
        WithUser {
            Text("Sign in to see your profile here")
        } content: { user, userInfo in
            NavigationStack {
                UserProfileView(userId: user.uid)
            }
        }
    }
}

struct MyProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        MyProfilePage()
            .environmentObject(UserManager())
    }
}
