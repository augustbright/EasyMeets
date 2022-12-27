//
//  HomePage.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 26.12.2022.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var data: DataModel;
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Upcoming events")
                        .font(.headline)
                    NavigationLink {
                        CreateEventPage()
                    } label: {
                        Label("Create event", systemImage: "plus.app")
                            .labelStyle(.iconOnly)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .environmentObject(DataModel())
    }
}
