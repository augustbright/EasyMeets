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
    @Published var bio: String = ""
    
    lazy var form = {
        FormValidation(validationType: .immediate)
    }()
    
    lazy var displayNameValidation: ValidationContainer = {
        $displayName.nonEmptyValidator(form: form, errorMessage: "Cannot be empty")
    }()
}

struct UserProfileView: View {
    @State private var debug = "debug"

    var userId: String
    var isCurrentUser: Bool = false
    
    @State private var isEditing = false
    @ObservedObject var formInfo = ProfileFormInfo()

    @State private var showPhotoDialog = false
    @State private var showSubscribersSheet = false
    @State private var showInvitationsSheet = false
    @State private var showInviteUserSheet = false
    @State private var showSignOutConfirmation = false
    @State private var showImagePicker = false
    
    @State private var photoData: Data?
    @State private var photoChanged = false

    @State private var userInfo: UserInfoModel?
    
    @State private var isLoading = false
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
//            Text(debug).font(.caption)
            ZStack {
                readContent
                    .opacity( isEditing ? 0 : 1)
                editContent
                    .opacity( isEditing ? 1 : 0)
            }
        }
        .onAppear {
            listenUserInfo()
        }
        .navigationTitle("Edit profile")
        .toolbar {
            if isSaving || isLoading {
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                }
            } else {
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
                                initAvatarData(userInfo: self.userInfo)
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
        .toolbar(isEditing ? .hidden : .visible, for: .tabBar)
        .coordinateSpace(name: "ProfileSpace")
    }
    
    var readContent: some View {
        VStack {
            avatarView
            header.zIndex(10)
            if let userInfo {
                Section {
                    HStack {
                        Text("\(userInfo.subscribers.count) subscribers")
                        Button("View") {
                            showSubscribersSheet = true
                        }
                        .sheet(isPresented: $showSubscribersSheet) {
                            UserSubscribersSheet()
                                .presentationDetents([.medium, .large])
                        }
                    }
                    .padding(.top, 35)
                    
                    HStack {
                        if isCurrentUser {
                            Button("\(userInfo.invitations.count) Invitations") {
                                showInvitationsSheet = true
                            }
                            .sheet(isPresented: $showInvitationsSheet) {
                                UserInvitationsSheet()
                                    .presentationDetents([.medium, .large])
                            }
                            .buttonStyle(.bordered)
                        } else {
                            NavigationLink {
                                UserInviteView()
                            } label: {
                                Label("Invite", systemImage: "envelope.fill")
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Subscribe") {}
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    HStack {
                        Text(userInfo.bio)
                            .padding(.vertical)
                            .foregroundColor(.secondary)
                    }
                    
                    List {
                        NavigationLink {
                            UserPlanView()
                        } label: {
                            Text("Plans")
                                .badge(userInfo.eventsAttending.count + userInfo.eventsMaybe.count)
                        }
                        
                        Section("Owner of") {
                            NavigationLink {
                                UserEventsView()
                            } label: {
                                Text("Events")
                                    .badge(userInfo.eventsOwn.count)
                            }
                            NavigationLink {
                                UserCommunitiesView()
                            } label: {
                                Text("Communities")
                                    .badge(userInfo.communitiesOwn.count)
                            }
                        }
                        if !isCurrentUser {
                            Section("Report") {
                                Button("Add to black-list") {}
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section("Account") {
                            NavigationLink {
                                AccountSettingsView()
                            } label: {
                                Text("Account settings")
                            }
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
                            },
                                                message: {
                                Text("Do you want to sign out?")
                            }
                            )
                            
                        }
                        
                    }
                    .scrollDisabled(true)
                    .frame(height: 560)
                }
            }
        }
    }
    
    var editContent: some View {
        VStack {
            avatarEdit
            Form {
                LabeledContent("Name") {
                    TextField("Display name", text: $formInfo.displayName)
                }
                .validation(formInfo.displayNameValidation)
                
                TextField("Tell about yourself...", text: $formInfo.bio, axis: .vertical)
                    .lineLimit(2...)
            }
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
                initAvatarData(userInfo: userInfo)
                prepareForm(userInfo: userInfo)
            }
        }
    }
    
    private func initAvatarData(userInfo: UserInfoModel?) {
        if let image = userInfo?.avatar {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let pictureRef = storageRef.child(image)
            
            pictureRef.getData(maxSize: Int64(20 * 1024 * 1024)) { data, error in
                if let error = error {
                    // Error occured
                } else {
                    photoData = data!
                    photoChanged = false
                    isLoading = false
                }
            }
        }
    }
    
    private func prepareForm(userInfo: UserInfoModel) {
        formInfo.displayName = userInfo.displayName
        formInfo.bio = userInfo.bio
    }
    
    var avatarView: some View {
        VStack {
            if let photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.white, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                    .frame(width: 200, height: 200)
            } else if let userInfo {
                Circle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .overlay {
                        Text(userInfo.displayName.prefix(1))
                            .foregroundColor(.secondary)
                            .font(.custom("", size: 65))
                            .bold()
                    }
                    .frame(width: 200, height: 200)
            }
        }
    }
    
    var avatarEdit: some View {
        VStack {
            if let photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.white, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                    .frame(width: 200, height: 200)
                    .onTapGesture {
                        showPhotoDialog = true
                    }
            } else if let userInfo {
                Circle().stroke(.gray, lineWidth: 1)
                    .background(Circle().fill(Color(UIColor.systemGroupedBackground))
                        .overlay {
                            Text(userInfo.displayName.prefix(1))
                                .foregroundColor(.secondary)
                                .font(.custom("", size: 65))
                                .bold()
                        }
                    )
                    .onTapGesture {
                        self.showImagePicker = true
                    }
                    .frame(width: 200)
            }
        }
        .confirmationDialog("Change Photo", isPresented: $showPhotoDialog) {
            Button("Remove", role: .destructive) {
                self.photoData = nil
                self.photoChanged = true
            }
            Button("Change") {
                self.showImagePicker = true
            }
            Button("Cancel", role: .cancel) {
                self.showPhotoDialog = false
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker() {
                imageData in self.photoData = imageData
                photoChanged = true
            }
        }
    }
    
    func calculateHeaderAlpha(y: Double) -> Double {
        if (y > 50) { return 0 }
        if (y < 0) { return 1 }
        
        return 1 - (y / 50)
    }
    
    func calculateHeaderFontSize(y: Double) -> CGFloat {
        if (y > 100) { return 30 }
        if (y < 0) { return 20 }
        
        return 20 +
        ( (y / 100) * (30 - 20) )
    }
    
    var header: some View {
        GeometryReader {
            geometry in
            VStack {
                HStack { Spacer()}
                
                Text(userInfo?.displayName ?? "")
                    .font(.system(size: calculateHeaderFontSize(y: geometry.frame(in: .named("ProfileSpace")).origin.y), weight: .regular, design: .default))
                    .bold()
                Spacer()
            }
            .background(Color(
                UIColor.systemGroupedBackground
                    .withAlphaComponent(calculateHeaderAlpha(y: geometry.frame(in: .named("ProfileSpace")).origin.y))
            ))
            .frame(
                width: geometry.size.width,
                height: 40)
            .offset(
                x: geometry.frame(in: .local).origin.x,
                y: geometry.frame(in: .named("ProfileSpace")).origin.y < 0 ? -geometry.frame(in: .named("ProfileSpace")).origin.y :
                    0
            )
        }
    }
    
    private func uploadPhoto(completion: @escaping ((String?, Error?) -> Void)) {
        if !photoChanged {
            completion(userInfo?.avatar, nil)
            return
        }

        if let photoData {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageName = UUID().uuidString + "-avatar.png"
            let imagePath = "user/\(userId)/\(imageName)"
            let imageRef = storageRef.child(imagePath)
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            let uploadTask = imageRef.putData(photoData, metadata: metadata) { (metadata, error) in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                completion(imagePath, nil)
            }
        } else {
            completion(nil, nil)
        }
        
    }

    func save() {
        self.debug = "saving"
        self.isSaving = true
        let userRef = Firestore.firestore().collection("Users").document(userId)
        
        uploadPhoto() {
            photoUrl, error in
            guard error == nil else {
                self.debug = "Error: \(error.debugDescription)"
                //TODO: Error occured
                self.isSaving = false
                return
            }
            
            userRef.updateData([
                "avatar": photoUrl,
                "displayName": formInfo.displayName,
                "bio": formInfo.bio
            ])

            self.isSaving = false
            isEditing = false
        }
        
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                UserProfileView(
                    userId: "oqf0IbCqDfYWwO0pGHaLnH4EYBe2",
                    //                    userInfo: UserInfoModel(
                    //                        displayName: "Mr. Elephant, nice to see you",
                    //                        avatar: "misc/Asian-Elephant-687x1030.jpg",
                    //                        bio: "Anyway, I'm just polite.",
                    //                        interests: ["123"],
                    //                        subscribers: ["234", "345"],
                    //                        invitations: ["qwe", "wert", "tyr"],
                    //                        eventsAttending: ["qwe", "qwe"],
                    //                        eventsMaybe: ["1"],
                    //                        eventsStarred: [],
                    //                        eventsOwn: ["1", "2", "3", "4", "5", "6", "7"],
                    //                        communitiesOwn: ["2", "42"],
                    //                        usersSubscriptions: ["a", "b"],
                    //                        communitiesSubscriptions: ["c", "d", "e"],
                    //                        usersBlackList: ["1"],
                    //                        communitiesBlackList: ["1234"]
                    //                    ),
                    isCurrentUser: true
                )
            }
            .previewDisplayName("Current user")
            
            NavigationStack {
                UserProfileView(
                    userId: "oqf0IbCqDfYWwO0pGHaLnH4EYBe2",
                    
                    //                    userInfo: UserInfoModel(
                    //                        displayName: "Mr. Elephant, nice to see you",
                    //                        avatar: "misc/Asian-Elephant-687x1030.jpg",
                    //                        bio: "Anyway, I'm just polite.",
                    //                        interests: ["123"],
                    //                        subscribers: ["234", "345"],
                    //                        invitations: ["qwe", "wert", "tyr"],
                    //                        eventsAttending: ["qwe", "qwe"],
                    //                        eventsMaybe: ["1"],
                    //                        eventsStarred: [],
                    //                        eventsOwn: ["1", "2", "3", "4", "5", "6", "7"],
                    //                        communitiesOwn: ["2", "42"],
                    //                        usersSubscriptions: ["a", "b"],
                    //                        communitiesSubscriptions: ["c", "d", "e"],
                    //                        usersBlackList: ["1"],
                    //                        communitiesBlackList: ["1234"]
                    //                    ),
                    
                    isCurrentUser: false
                )
            }
            .previewDisplayName("Other user")
        }
    }
}
