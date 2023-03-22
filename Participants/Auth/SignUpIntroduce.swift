//
//  SignUpIntroduce.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 22.03.2023.
//

import SwiftUI
import FormValidator

class IntroduceFormInfo: ObservableObject {
    @Published var displayName: String = ""
    
    lazy var form = {
        FormValidation(validationType: .immediate)
    }()
    
    lazy var displayNameValidation: ValidationContainer = {
        $displayName.nonEmptyValidator(form: form, errorMessage: "Cannot be empty")
    }()
}

struct SignUpIntroduce: View {
    @EnvironmentObject private var userManager: UserManager;
    @ObservedObject private var formInfo = IntroduceFormInfo()
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("Tell us your name")
                .font(.title)
            TextField("Name", text: $formInfo.displayName)
                .validation(formInfo.displayNameValidation)
                .textFieldStyle(.roundedBorder)
                .padding()
                .controlSize(.large)
            Button("Next") { next() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Button("Cancel") { cancel() }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .padding()
        }
        .disabled(isLoading)
    }
    
    func next() {
        formInfo.form.triggerValidation()
        if let userId = userManager.user?.uid {
            isLoading = true
            UserManager.createUserInfo(userId: userId, displayName: formInfo.displayName) { error, id in
                isLoading = false
            }
        }
    }
    
    func cancel() {
        userManager.signOut()
    }
}

struct SignUpIntroduce_Previews: PreviewProvider {
    static var previews: some View {
        SignUpIntroduce()
            .environmentObject(UserManager())
    }
}
