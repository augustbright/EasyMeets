//
//  MyProfilePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct MyProfilePage: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        WithUser{
            Text("Sign in to see your profile here")
        } content: { user, userInfo in
            UserPlanView()
        }
    }
}

struct MyProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyProfilePage()
                .environmentObject(UserManager())
        }
    }
}
