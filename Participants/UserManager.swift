//
//  UserManager.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 30.12.2022.
//

import Foundation
import FirebaseAuth
import SwiftUI

class UserManager: ObservableObject {
    @Published var user: User?
    
    init() {
        listen()
    }

    init(autoLogin: Bool) {
        if autoLogin {
            Auth.auth().signIn(withEmail: "", password: "") {
                [weak self] (result, error) in if let user = result?.user {
                    guard let self = self else {
                        return
                    }

                    self.user = user
                }
            }
        }
        listen()
    }
    
    private func listen() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
        }
    }
}
