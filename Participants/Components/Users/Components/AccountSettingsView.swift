//
//  SettingsView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 16.01.2023.
//

import SwiftUI

struct AccountSettingsView: View {
    enum PrivacyScope: String, CaseIterable, Identifiable {
        case everybody, iFollow, nobody
        var id: Self { self }
    }

    @State private var isPublic = false
    @State private var selectedPlans: PrivacyScope = .everybody
    @State private var selectedInviteMe: PrivacyScope = .everybody

    var body: some View {
        Form {
            Section("Authentification") {
                LabeledContent("Email") {
                    Text("foo@mail.com")
                    Button("Change") {}
                }
                LabeledContent("Password") {
                    Text("***")
                    Button("Change") {}
                }
            }
            
            Section("Privacy") {
                Picker("Who can see my plans?", selection: $selectedPlans) {
                    Text("Everybody").tag(PrivacyScope.everybody)
                    Text("People I follow").tag(PrivacyScope.iFollow)
                    Text("Nobody").tag(PrivacyScope.nobody)
                }
                
                Picker("Who can invite me?", selection: $selectedInviteMe) {
                    Text("Everybody").tag(PrivacyScope.everybody)
                    Text("People I follow").tag(PrivacyScope.iFollow)
                    Text("Nobody").tag(PrivacyScope.nobody)
                }
            }
        }
    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
    }
}
