//
//  ContentView.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL

struct ContentView: View {
    var databaseDataApp: [DatabaseData]
    var qnet: DeepQNetwork
    var actionsArray: [Action]
    
    var body: some View {
        NavigationView {
            List(databaseDataApp) { data in
                NavigationLink {
                    Detail(data: data, qnet: qnet, actionsArray: actionsArray)
                } label: {
                    Row(data: data)
                }
            }
            .navigationTitle("Agent's Actions Preview")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
