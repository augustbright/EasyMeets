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
import Firebase
import FormValidator

class EventFormInfo: ObservableObject {
    @Published var title: String = ""
    @Published var startDate: Date = Calendar.current.date(byAdding: DateComponents(day: 1), to: Calendar.current.startOfDay(for: Date.now))!
    @Published var finishDate: Date = Date.now
    @Published var hasFinishDate: Bool = false
    
    lazy var form = {
        FormValidation(validationType: .immediate)
    }()

    lazy var titleValidation: ValidationContainer = {
        $title.nonEmptyValidator(form: form, errorMessage: "Title cannot be empty")
    }()
    
    lazy var startDateValidation: ValidationContainer = {
        $startDate.dateValidator(form: form, after: Date.now, errorMessage: "Start time cannot be in the past")
    }()
    
    lazy var finishDateValidation: ValidationContainer = {
        $finishDate.dateValidator(form: form, after: startDate, errorMessage: "Finish time should be after the start time", disableValidation: {
            !self.hasFinishDate
        })
    }()
}

struct Location : Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
}

extension Location {
    static func getLocations() -> [Location] {
        return [
            Location(title: "Custom", coordinate:
                        CLLocationCoordinate2D(latitude: 41.715137, longitude: 44.807095))
        ]
    }
}

struct CreateEventPage: View {
    @EnvironmentObject var locationManager: LocationManager;
    @EnvironmentObject var userManager: UserManager;
    @ObservedObject var formInfo = EventFormInfo()

    private var eventDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: formInfo.startDate, to: formInfo.finishDate) ?? ""
    }
    
    private var defaultFinishTime: Date {
        var dateComponent = DateComponents()
        dateComponent.hour = 1
        return Calendar.current.date(byAdding: dateComponent, to: formInfo.startDate)!
    }

    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var isPublished: Bool = true
    @State private var community: CommunityModel?
    
    @State private var docId: String = ""
    
    @State private var isOnline: Bool = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.715137, longitude: 44.807095),
        latitudinalMeters: 3000,
        longitudinalMeters: 3000
    )
    @State private var locations: [Location] = Location.getLocations()
    @State private var linkToEvent = ""
    @State private var locationAdditionalInfo = ""
    
    enum EventType: String, CaseIterable, Identifiable {
        case Personal, Community
        var id: Self { self }
    }
    
    @State private var eventType: EventType = .Personal
        
    @State private var description = ""
        
    var body: some View {
        WithUser {
            Text("Sign in to create an event")
        } content: { user, _ in
            Form {
                Section("General") {
                    TextField("Title", text: $formInfo.title)
                        .validation(formInfo.titleValidation)
                        .textFieldStyle(.roundedBorder)
                    Picker("Event type", selection: $eventType) {
                        Text("Personal").tag(EventType.Personal)
                        Text("Community").tag(EventType.Community)
                    }
                    .onChange(of: eventType) { [eventType] eventType in
                        if eventType == .Personal {
                            community = nil
                        }
                    }
                    if eventType == .Community {
                        CommunityPicker(community: $community)
                    }
                    Toggle(isOn: $isPublished) {
                        Text("Public")
                    }
                }
                
                Section("Time") {
                    DatePicker(selection: $formInfo.startDate, label: { Text("Starts") })
                        .validation(formInfo.startDateValidation)
                        .onChange(of: formInfo.startDate) {
                            _ in formInfo.finishDate = defaultFinishTime
                        }
                    Toggle(isOn: $formInfo.hasFinishDate) {
                        Text("End time")
                    }
                    if formInfo.hasFinishDate {
                        DatePicker(selection: $formInfo.finishDate, label: { Text("Ends") })
                            .validation(formInfo.finishDateValidation)
                        LabeledContent("Duration", value: eventDuration)
                    }
                }
                
                Section("Location") {
                    Toggle(isOn: $isOnline) {
                        Text("Online")
                    }
                    if !isOnline {
                        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: locations) {
                            (location) -> MapPin in MapPin(coordinate: region.center)
                        }
                        .frame(height: 200.0)
                        
                    } else {
                        HStack {
                            TextField("Link to event", text: $linkToEvent)
                        }
                    }
                    TextField("Additional info", text: $locationAdditionalInfo, axis: .vertical)
                        .lineLimit(2...)
                }
                
                Section("Picture") {
                    ImageDataPicker(photoItem: $photoItem, photoData: $photoData)
                }
                
                Section("About this event") {
                    TextField("About this event...", text: $locationAdditionalInfo, axis: .vertical)
                        .lineLimit(2...)
                }
            }
            .navigationTitle("Create a new event")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        save()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!formInfo.form.allValid)
                }
            }
        }
    }
    
    private func save() {
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
        if let authorId = userManager.user?.uid {
            let eventModel = EventModel(
                title: formInfo.title,
                description: description,
                imagePreview: photoUrl,
                startDate: formInfo.startDate.ISO8601Format(),
                finishDate: formInfo.finishDate.ISO8601Format(),
                address: "",
                longtitude: region.center.longitude,
                latitude: region.center.latitude,
                authorId: authorId,
                communityId: community?.id,
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
        NavigationStack {
            CreateEventPage()
                .environmentObject(LocationManager(mock: true))
                .environmentObject(UserManager())
        }
    }
}
