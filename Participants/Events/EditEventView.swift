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
    @Published var description: String = ""
    @Published var startDate: Date = Calendar.current.date(byAdding: DateComponents(day: 1), to: Calendar.current.startOfDay(for: Date.now))!
    
    lazy var form = {
        FormValidation(validationType: .immediate)
    }()

    lazy var descriptionValidation: ValidationContainer = {
        $description.nonEmptyValidator(form: form, errorMessage: "This field cannot be empty")
    }()
    
    lazy var startDateValidation: ValidationContainer = {
        $startDate.dateValidator(form: form, after: Date.now, errorMessage: "Enter a future date")
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

    @State private var docId: String = ""

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.715137, longitude: 44.807095),
        latitudinalMeters: 3000,
        longitudinalMeters: 3000
    )
    @State private var locations: [Location] = Location.getLocations()
    @State private var locationAdditionalInfo = ""

    @State private var isSaving = false
    @State private var showingSuccessPopup = false
    @State private var error: Error?
        
    var body: some View {
        Form {
            Section("What are we gonna do?") {
                TextField("About this event...", text: $formInfo.description, axis: .vertical)
                    .lineLimit(2...)
                    .validation(formInfo.descriptionValidation)
            }


            Section("When") {
                DatePicker(selection: $formInfo.startDate, label: { Text("Starts") })
                    .validation(formInfo.startDateValidation)
            }

            Section("Where") {
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: locations) {
                    (location) -> MapPin in MapPin(coordinate: region.center)
                }
                .frame(height: 200.0)
                TextField("Additional info", text: $locationAdditionalInfo, axis: .vertical)
                    .lineLimit(2...)
            }
        }
        .disabled(isSaving)
        .navigationTitle("Let's meet...")
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
    
    private func initEventForm() {
        guard let originalEvent else { return }
        
        formInfo.startDate = originalEvent.startDateFormatted
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: originalEvent.latitude ?? 41.715137, longitude: originalEvent.longtitude ?? 44.807095),
            latitudinalMeters: 3000,
            longitudinalMeters: 3000
        )
        locationAdditionalInfo = originalEvent.locationAdditionalInfo
        formInfo.description = originalEvent.description
    }
    
    private func save(completion: @escaping (EventModel?, Error?) -> Void) {
        uploadModel(completion: completion)
    }
    
    private func uploadModel(completion: @escaping ((EventModel?, Error?) -> Void)) {
        if let authorId = userManager.user?.uid {
            var eventModel = EventModel(
                id: nil,
                authorId: authorId,
                authorName: userManager.user?.displayName ?? "",
                startDate: formInfo.startDate.ISO8601Format(),
                longtitude: region.center.longitude,
                latitude: region.center.latitude,
                locationAdditionalInfo: locationAdditionalInfo,
                description: formInfo.description,
                deleted: false,
                peopleAttending: []
            );
            EventManager().saveEvent(eventModel, id: originalEvent?.id) {
                eventId, error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                eventModel.id = eventId
                userManager.ownEvent(eventId: eventId!)
                completion(eventModel, nil)
            }
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
