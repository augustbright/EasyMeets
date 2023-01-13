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

struct EditEventView: View {
    var originalEvent: EventModel?
    var onFinish: (EventModel?, Error?) -> Void

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

    @State private var photoData: Data?
    @State private var isPublished: Bool = true
    @State private var community: CommunityPickerItem?

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
    
    @State private var isSaving = false
    @State private var confetties: Int = 0
    @State private var showingSuccessPopup = false
    @State private var error: Error?
        
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
                    ImageDataPicker(photoData: $photoData)
                }

                Section("About this event") {
                    TextField("About this event...", text: $description, axis: .vertical)
                        .lineLimit(2...)
                }
            }
            .disabled(isSaving)
            .navigationTitle(originalEvent == nil ? "Create a new event" : "Edit event")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        self.isSaving = true
                        save() {
                            event, error in
                            self.isSaving = false
                            onFinish(event, error)
                        }
                        self.showingSuccessPopup = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!formInfo.form.allValid || isSaving)
                }

                if let originalEvent, let eventId = originalEvent.id {
                    ToolbarItem(placement: .secondaryAction) {
                        Button("Delete event", role: .destructive) {
                            EventManager.deleteEvent(eventId) {
                                error in
                                guard error == nil else {
                                    onFinish(nil, error)
                                    return
                                }
                                var deletedEvent = EventModel(data: originalEvent.dictionary, id: eventId)
                                deletedEvent.deleted = true
                                onFinish(deletedEvent, nil)
                            }
                        }
                    }
                }
            }
            .onAppear { initEventForm() }
        }
    }
    
    private func initEventForm() {
        guard let originalEvent else { return }
        
        formInfo.title = originalEvent.title
        eventType = originalEvent.communityId == nil ? .Personal : .Community
        
        if eventType == .Community {
            community = CommunityPickerItem(id: originalEvent.communityId!, name: originalEvent.communityName!)
        }
        
        isPublished = originalEvent.published
        
        formInfo.startDate = originalEvent.startDateFormatted
        formInfo.finishDate = originalEvent.finishDateFormatted ?? defaultFinishTime
        formInfo.hasFinishDate = originalEvent.finishDateFormatted != nil

        isOnline = originalEvent.isOnline

        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: originalEvent.latitude ?? 41.715137, longitude: originalEvent.longtitude ?? 44.807095),
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )

        linkToEvent = originalEvent.eventLink ?? ""
        
        locationAdditionalInfo = originalEvent.locationAdditionalInfo
        
        if let image = originalEvent.image {
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
        
        description = originalEvent.description
    }
    
    private func save(completion: @escaping (EventModel?, Error?) -> Void) {
        uploadPhoto() {
            (url, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            uploadModel(photoUrl: url, completion: completion)
        }
    }
    
    private func uploadModel(photoUrl: String?, completion: @escaping ((EventModel?, Error?) -> Void)) {
        if let authorId = userManager.user?.uid {
            var eventModel = EventModel(
                id: nil,
                title: formInfo.title,

                authorId: authorId,
                authorName: userManager.user?.displayName ?? "",
                communityId: community?.id,
                communityName: community?.name,

                startDate: formInfo.startDate.ISO8601Format(),
                finishDate: formInfo.finishDate.ISO8601Format(),

                image: photoUrl,

                isOnline: isOnline,
                longtitude: region.center.longitude,
                latitude: region.center.latitude,
                address: "",
                locationAdditionalInfo: locationAdditionalInfo,

                description: description,

                published: isPublished,
                deleted: false,
                peopleAttending: [],
                peopleThinking: []
            );
            EventManager().saveEvent(eventModel, id: originalEvent?.id) {
                eventId, error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                eventModel.id = originalEvent?.id
                userManager.ownEvent(eventId: eventId!)
                completion(eventModel, nil)
            }
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

struct EditEventView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditEventView(originalEvent: EventModel.mock) { _, _ in }
                .environmentObject(UserManager())
        }
    }
}
