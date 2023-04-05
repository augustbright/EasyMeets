//
//  UserProfileView.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 15.01.2023.
//

import SwiftUI
import FirebaseAuth
import PhotosUI
import FirebaseStorage
import FormValidator
import FirebaseFirestore

class ProfileFormInfo: ObservableObject {
    @Published var displayName: String = ""
    
    lazy var form = {
        FormValidation(validationType: .immediate)
    }()
    
    lazy var displayNameValidation: ValidationContainer = {
        $displayName.nonEmptyValidator(form: form, errorMessage: "Cannot be empty")
    }()
}

struct UserProfileView: View {
    var userId: String
    var isActive: Bool
    
    @State private var debug = "debug"
    @EnvironmentObject private var userManager: UserManager
    @ObservedObject var formInfo = ProfileFormInfo()
    @State private var isCurrentUser: Bool = false
    @State private var isEditing = false
    @State private var showSignOutConfirmation = false
    @State private var userInfo: UserInfoModel?
    @State private var isLoading = false
    @State private var isSaving = false
    
    @State private var feedbacksListener: ListenerRegistration?
    @State private var feedbacks: [FeedbackModel]?
    
    var positiveFeedbacks: [FeedbackModel]? {
        guard let feedbacks = self.feedbacks else {
            return nil;
        }
        return feedbacks.filter { $0.liked == true }
    }
    
    var body: some View {
        VStack {
            ZStack {
                editContent
                    .opacity( isEditing ? 1 : 0)
                readContent
                    .opacity( isEditing ? 0 : 1)
            }
        }
        .onAppear {
            isCurrentUser = userId == userManager.user?.uid
            listenUserInfo()
            self.listenRating(userInfo: self.userInfo)
        }
        .onChange(of: self.userInfo) { userInfo in
            self.listenRating(userInfo: self.userInfo)
        }
        .navigationTitle(userInfo?.displayName ?? "")
        .toolbar {
            if self.isActive {
                if isSaving || isLoading {
                    ToolbarItem(placement: .primaryAction) {
                        ProgressView()
                    }
                } else if isCurrentUser {
                    if !isEditing {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Edit") {
                                withAnimation {
                                    isEditing = true
                                }
                            }
                        }
                    } else {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                withAnimation {
                                    isEditing = false
                                }
                            }
                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            Button("Save") {
                                withAnimation {
                                    save()
                                }
                            }
                        }
                    }
                }
            }
        }
        .toolbar(isEditing ? .hidden : .visible, for: .tabBar)
        .coordinateSpace(name: "ProfileSpace")
    }
    
    var readContent: some View {
        VStack {
            if let positiveFeedbacks, positiveFeedbacks.count > 0 {
                HStack {
                    VStack() {
                        Text("\(positiveFeedbacks.count) ❤️")
                            .bold()
                            .font(.title)
                        Text("feedbacks")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.tertiarySystemBackground)))
                    
                    Spacer()
                }
                .padding(20)
            }
            Form {
                NavigationLink("Plans") {
                    MyPlansPage()
                }

                NavigationLink("History") {
                    HistoryPage()
                }

                Section("Account") {
                    Button("Sign out", role: .destructive) {
                        showSignOutConfirmation = true
                    }
                    .confirmationDialog(Text("Sign out"),
                                        isPresented: $showSignOutConfirmation,
                                        titleVisibility: .automatic,
                                        actions: {
                        Button("Sign out", role: .destructive) {
                            do {
                                try Auth.auth().signOut()
                            } catch {}
                        }
                        Button("Cancel", role: .cancel) {
                            showSignOutConfirmation = false
                        }
                    }, message: {
                        Text("Do you want to sign out?")
                    }
                    )
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    var editContent: some View {
        Form {
            LabeledContent("Name") {
                TextField("Display name", text: $formInfo.displayName)
            }
            .validation(formInfo.displayNameValidation)
        }
        .disabled(isSaving || isLoading)
    }
    
    private func listenUserInfo() {
        let userRef = Firestore.firestore().collection("Users").document(userId)
        userRef.addSnapshotListener() {
            snapshot, error in
            guard error == nil else { return }
            guard snapshot != nil else { return }
            
            isLoading = true
            
            if let data = snapshot?.data() {
                let userInfo = UserManager.userInfoFromData(data)
                self.userInfo = userInfo
                formInfo.displayName = userInfo.displayName
                isLoading = false
            }
        }
    }
    
    private func save() {
        if !formInfo.form.allValid {
            return
        }
        
        let userRef = Firestore.firestore().collection("Users").document(userId)
        userRef.updateData([
            "displayName": formInfo.displayName,
        ])
        isEditing = false
    }
    
    private func listenRating(userInfo: UserInfoModel?) {
        if let currentListener = self.feedbacksListener {
            currentListener.remove()
        }
        guard let userInfo else {
            self.feedbacks = nil
            return
        }
        guard !userInfo.eventsOwn.isEmpty else {
            self.feedbacks = nil
            return
        }

        self.feedbacksListener = Firestore.firestore().collectionGroup("feedbacks")
            .whereField("eventId", in: userInfo.eventsOwn).addSnapshotListener { snapshot, error in
                guard error == nil else {
                    self.feedbacks = nil
                    return;
                }
                guard snapshot != nil else {
                    self.feedbacks = nil
                    return
                }

                self.feedbacks = snapshot?.documents.map { documentSnapshot in
                    let data = documentSnapshot.data()
                    return createFeedbackModelFromData(data)
                }
            }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                UserProfileView(
                    userId: "4bR1KOGJF0Vbm2uck2ibQUEfJBz1",
                    isActive: true
                )
            }
            .previewDisplayName("Current user")
            
            NavigationStack {
                UserProfileView(
                    userId: "lSghPbO1UDQDxfYTAcRv06f7clk1",
                    isActive: true
                )
            }
            .previewDisplayName("Other user")
        }
        .environmentObject(UserManager())
    }
}
