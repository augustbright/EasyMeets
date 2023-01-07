//
//  ImageDataPicker.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 27.12.2022.
//

import SwiftUI
import PhotosUI

struct ImageDataPicker: View {
    @Binding var photoItem: PhotosPickerItem?
    @Binding var photoData: Data?
    
    var body: some View {
        VStack {
            if let photoData,
               let uiImage = UIImage(data: photoData) {

                Menu {
                    Button(role: .destructive) {
                        self.photoData = nil
                    } label: {
                        Label("Delete", systemImage: "xmark")
                    }
                } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
            } else {
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    Label("Pick a photo", systemImage: "photo")
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
    }
}

struct ImageDataPicker_Previews: PreviewProvider {
    static var previews: some View {
        ImageDataPicker(photoItem: .constant(nil), photoData: .constant(nil))
    }
}
