//
//  SignUpView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 24.01.2023.
//

import SwiftUI
import FormValidator
import FirebaseAuth

protocol BoolValidator: FormValidator {
    var value: Bool { get set }
    func validate() -> Validation
}

public class CheckedValidator: BoolValidator {
    public var isEmpty: Bool = true
    
    public var publisher: ValidationPublisher!
    public var subject: ValidationSubject = .init()
    public var onChanged: [OnValidationChange] = []

    public var errorMessage: StringProducerClosure = {
        ""
    }
    public var value: Bool = false

    public func validate() -> Validation {
        if !value {
            return .failure(message: errorMessage())
        }
        return .success
    }
}

extension Published.Publisher where Value == Bool {
    func checkedValidator(
            form: FormValidation,
            errorMessage: @autoclosure @escaping StringProducerClosure = ""
    ) -> ValidationContainer {
        let validator = CheckedValidator()
        let message = errorMessage()
        return ValidationPublishers.create(
                form: form,
                validator: validator,
                for: self.eraseToAnyPublisher(),
                errorMessage: !message.isEmpty ? message : form.messages.required)
    }
}

class SignUpFormInfo: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var displayName: String = ""
    @Published var agreementAccepted: Bool = false
    
    lazy var form = {
        FormValidation(validationType: .immediate)
    }()
    
    lazy var emailValidation: ValidationContainer = {
        $email
            .emailValidator(form: form)
    }()

    lazy var displayNameValidation: ValidationContainer = {
        $displayName
            .nonEmptyValidator(form: form)
    }()
    
    lazy var passwordValidation: ValidationContainer = {
        $password
            .patternValidator(form: form, pattern: "^[A-Za-z\\d$@$!%*#?&]{6,}$", errorMessage: "6 symbols minimum")
    }()
    
    lazy var passwordMatchValidation: ValidationContainer = {
        $passwordConfirm
            .passwordMatchValidator(form: form, firstPassword: self.password, secondPassword: self.passwordConfirm, secondPasswordPublisher: $passwordConfirm)
    }()

    lazy var agreementAcceptedValidation: ValidationContainer = {
        $agreementAccepted
            .checkedValidator(form: form)
    }()
}


struct SignUpModal: View {
    @ObservedObject var formInfo = SignUpFormInfo()
    @State var error: String?
    @State var isEmailSent = false
    @State var isLoading = false
    
    @State var message = "test"

    var body: some View {
        VStack {
            if !isEmailSent {
                form
            } else {
                success
            }
        }
    }
    
    var form: some View {
        Form {
            Section("Email & Name") {
                LabeledContent("Email") {
                    TextField("Type in your email", text: $formInfo.email)
                        .keyboardType(.emailAddress)
                }
                .validation(formInfo.emailValidation)

                LabeledContent("Name") {
                    TextField("Other people will see it", text: $formInfo.displayName)
                }
                .validation(formInfo.displayNameValidation)
            }
            
            Section("Password") {
                SecureField("Password", text: $formInfo.password)
                    .validation(formInfo.passwordValidation)
                SecureField("Confirm password", text: $formInfo.passwordConfirm)
                    .validation(formInfo.passwordMatchValidation)
            }
                        
            Section {
                Toggle("I agree to the User Agreement and Pravacy Policy", isOn: $formInfo.agreementAccepted)
                    .validation(formInfo.agreementAcceptedValidation)
                HStack {
                    Button("Register") {
                        if formInfo.form.triggerValidation() {
                            register()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    
                    if isLoading {
                        ProgressView()
                            .padding(.leading, 4)
                    }

                    Spacer()
                }
                .padding(.vertical)
                
                if let error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .disabled(isLoading)
    }
    
    var success: some View {
        VStack(alignment: .leading) {
            Text("Welcome to the party, *\(formInfo.displayName)*!")
                .font(.title)
            Text("We've sent you a verification email on _\(formInfo.email)_.")
                .padding(.top)
        }
    }
    
    func register() {
        self.isLoading = true
        Auth.auth().createUser(withEmail: formInfo.email, password: formInfo.password) { authResult, error in
            guard error == nil else {
                self.error = error?.localizedDescription
                self.isLoading = false
                return
            }
            
            guard let userId = authResult?.user.uid else {
                return
            }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = formInfo.displayName
            changeRequest?.commitChanges { error in
                guard error == nil else {
                    self.error = error?.localizedDescription
                    self.isLoading = false
                    return
                }

                authResult?.user.sendEmailVerification {
                    error in
                    guard error == nil else {
                        self.error = error?.localizedDescription
                        self.isLoading = false
                        return
                    }

                    UserManager.createUserInfo(userId: userId, displayName: formInfo.displayName) {
                        error, message in

                        if let message {
                            self.message = message
                        }

                        guard error == nil else {
                            self.error = error?.localizedDescription
                            self.isLoading = false
                            return
                        }

                        self.isEmailSent = true
                        self.isLoading = false
                        self.error = nil
                    }
                }
            }
        }
    }
}

struct SignUpModal_Previews: PreviewProvider {
    static var previews: some View {
        SignUpModal()
    }
}
