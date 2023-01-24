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

struct UserProfileView: View {
    var userInfo: UserInfoModel
    var isCurrentUser: Bool = false
    
    @State private var showPhotoDialog = false
    @State private var showSubscribersSheet = false
    @State private var showInvitationsSheet = false
    @State private var showInviteUserSheet = false
    @State private var showSignOutConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack {
                avatar
                header.zIndex(10)
                
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
                        Button("\(userInfo.invitations.count) Invitations") {
                            showInvitationsSheet = true
                        }
                        .sheet(isPresented: $showInvitationsSheet) {
                            UserInvitationsSheet()
                                .presentationDetents([.medium, .large])
                        }
                        .buttonStyle(.bordered)
                        NavigationLink {
                            UserInviteView()
                        } label: {
                            Label("Invite", systemImage: "envelope.fill")
                        }
                        .buttonStyle(.bordered)
                        Button("Subscribe") {}
                            .buttonStyle(.borderedProminent)
                    }
                    
                    HStack {
                        Text(userInfo.bio)
                            .padding(.vertical)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 50.0)
                    
                    List {
                        Section("Upcomings") {
                            NavigationLink {
                                UserPlanView()
                            } label: {
                                Text("Plans")
                                    .badge(userInfo.eventsAttending.count + userInfo.eventsMaybe.count)
                            }
                            NavigationLink {
                                UserInterestsView()
                            } label: {
                                Text("Interests")
                                    .badge(userInfo.interests.count)
                            }
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
                        
                        Section("Report") {
                            Button("Add to black-list") {}
                                .foregroundColor(.secondary)
                        }
                        
                        Section("Account") {
                            NavigationLink {
                                SettingsView()
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
                                Button("Sign out", role: .destructive) { }
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
        .coordinateSpace(name: "ProfileSpace")
    }
    
    @State var photoData: Data?
    @State private var photoItem: PhotosPickerItem?
    
    private func loadAvatarData() {
        if let image = userInfo.avatar {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let pictureRef = storageRef.child(image)

            pictureRef.getData(maxSize: Int64(5 * 1024 * 1024)) { data, error in
              if let error = error {
                // Uh-oh, an error occurred!
              } else {
                photoData = data!
              }
            }
        }
    }

    var avatar: some View {
        VStack {
            if let photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.white, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                    .frame(width: 200)
                    .onTapGesture {
                        showPhotoDialog = true
                    }
                    .confirmationDialog("Change Photo", isPresented: $showPhotoDialog) {
                        Button("Remove", role: .destructive) { }
                        Button("Change") { }
                        Button("Cancel", role: .cancel) {
                            showSignOutConfirmation = false
                        }
                    }
            } else {
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    Circle().stroke(.gray, lineWidth: 1)
                        .background(Circle().fill(Color(UIColor.systemGroupedBackground)))
                        .frame(width: 200)

                }
                .onChange(of: photoItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            self.photoItem = newItem
                            self.photoData = data
                        }
                    }
                }
            }
        }
        .onAppear { loadAvatarData() }
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
                
                Text(userInfo.displayName)
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
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserProfileView(
                userInfo: UserInfoModel(
                    displayName: "Mr. Elephant, nice to see you",
                    avatar: "misc/Asian-Elephant-687x1030.jpg",
                    bio: "Anyway, I'm just polite.",
                    interests: ["123"],
                    subscribers: ["234", "345"],
                    invitations: ["qwe", "wert", "tyr"],
                    eventsAttending: ["qwe", "qwe"],
                    eventsMaybe: ["1"],
                    eventsStarred: [],
                    eventsOwn: ["1", "2", "3", "4", "5", "6", "7"],
                    communitiesOwn: ["2", "42"],
                    usersSubscribtions: ["a", "b"],
                    communitiesSubscribtions: ["c", "d", "e"],
                    usersBlackList: ["1"],
                    communitiesBlackList: ["1234"]
                ),
                
                isCurrentUser: false
            )
        }
    }
}
