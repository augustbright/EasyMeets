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
    var isActive: Bool

    var body: some View {
        VStack {
            if let userUid = userManager.user?.uid {
                UserProfileView(userId: userManager.user!.uid, isActive: self.isActive)
            }
        }
    }
}

struct MyProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        MyProfilePage(isActive: true)
            .environmentObject(UserManager())
    }
}
