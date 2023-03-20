//
//  WelcomePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        SignUpSignIn {
            Text("Easy Meets")
        }
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage()
            .environmentObject(UserManager())
    }
}
