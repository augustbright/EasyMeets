//
//  CommunityPicker.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 09.01.2023.
//

import SwiftUI

struct CommunityPicker: View {
    @Binding var community: CommunityModel?
    @State private var isShown: Bool = false
    var body: some View {
        Button(community?.name ?? "Select community") {
            isShown = true
        }
        .sheet(isPresented: $isShown) {
            CommunitiesPickerList(community: $community, isShown: $isShown)
        }
        
    }
}

struct CommunityPicker_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CommunityPicker(community: .constant(CommunityModel(authorId: "", name: "Foo", description: "Test", followers: ["1"])))
                .previewDisplayName("Selected")
            
            CommunityPicker(community: .constant(nil))
                .previewLayout(PreviewLayout.sizeThatFits)
                .previewDisplayName("Empty")
        }
    }
}
