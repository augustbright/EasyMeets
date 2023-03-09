//
//  FavoriteButton.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet: Bool;
    var body: some View {
        Button {
            isSet.toggle()
        } label: {
            Label("Toggle favorite", systemImage: isSet ? "heart.fill" : "heart")
                .foregroundColor(isSet ? .red : .gray)
                .labelStyle(.iconOnly)
        }
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(isSet: .constant(true))
    }
}
