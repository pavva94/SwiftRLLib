//
//  Row.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL

struct Row: View {
    var data: DatabaseData

    var body: some View {
        HStack {
            Text("ID")
            Text(String(data.id))
            Spacer()
        }
    }
}
