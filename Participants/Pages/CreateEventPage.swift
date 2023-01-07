//
//  CreateEventPage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 25.12.2022.
//

import SwiftUI
import PhotosUI
import MapKit
import FirebaseStorage

struct CreateEventPage: View {
    let calendar = Calendar.current
    @EnvironmentObject var locationManager: LocationManager;
    @EnvironmentObject var userManager: UserManager;
    @State private var title = ""
    @State private var description = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var startDate: Date = Date.now
    @State private var finishDate: Date = Date.now
    @State private var hasFinishDate: Bool = false
    
    @State private var docId: String = ""
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.715137, longitude: 44.807095),
        latitudinalMeters: 3000,
        longitudinalMeters: 3000
    )
    
    var body: some View {
        if userManager.user == nil {
            LoginPage() {
                Text("Sign in to create an event")
            }
        } else {

                VStack(spacing: 20.0) {
                    Text("Create a new event...")
                        .font(.title)
                    ScrollView {
                    VStack {
                        
                        Text("Event title:").font(.caption)
                        TextField("Title", text: $title)
                            .textFieldStyle(.roundedBorder)
                        
                        DatePicker(selection: $startDate, label: { Text("Starts") })
                        
                        if hasFinishDate {
                            HStack {
                                DatePicker(selection: $finishDate, label: { Text("Ends") })
                                Button {
                                    hasFinishDate = false
                                } label: {
                                    Label("Clear", systemImage: "xmark")
                                        .labelStyle(.iconOnly)
                                }
                            }
                        } else {
                            HStack {
                                Spacer()
                                Button {
                                    finishDate = calendar.date(byAdding: .hour, value: 1, to: startDate) ?? Date.now
                                    hasFinishDate = true
                                } label: {
                                    Label("End time", systemImage: "plus")
                                }
                            }
                        }
                    }
                    
                    VStack {
                        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none)
                            .frame(height: 200.0)
                    }
                    
                    HStack {
                        Spacer()
                        VStack {
                            ImageDataPicker(photoItem: $photoItem, photoData: $photoData)
                        }
                        Spacer()
                    }
                    .frame(minHeight: photoData == nil ? 200 : nil)
                    .border(photoData == nil ? .gray : .white)
                    
                    Text("About this event:").font(.caption)
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                        .border(.gray)
                    
                    Button("Submit") {
                        createEvent()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func createEvent() {
        uploadPhoto() {
            (url, error) in
            guard error == nil else {
                return
            }
            uploadModel(photoUrl: url) {
                error in
            }
        }
    }
    
    private func uploadModel(photoUrl: String?, completion: @escaping ((Error?) -> Void)) {
        if let authorId = userManager.user?.uid, let photoUrl = photoUrl {
            let eventModel = EventModel(
                title: title,
                description: description,
                imagePreview: photoUrl,
                startDate: startDate.ISO8601Format(),
                address: "",
                longtitude: region.center.longitude,
                latitude: region.center.latitude,
                authorId: authorId,
                peopleAttending: [],
                peopleThinking: []
            );
            docId = EventManager().createEvent(eventModel, completion: completion)
        }
    }
    
    private func uploadPhoto(completion: @escaping ((String?, Error?) -> Void)) {
        if let photoData {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageName = UUID().uuidString + ".png"
            let imagePath = "user/\(userManager.user?.uid ?? "no-user")/\(imageName)"
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
}

struct CreateEventPage_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventPage()
            .environmentObject(LocationManager(mock: true))
            .environmentObject(UserManager(autoLogin: true))
    }
}
