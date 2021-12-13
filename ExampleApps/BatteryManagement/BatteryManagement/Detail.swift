//
//  Detail.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL
import CoreML


struct Detail: View {
    var data: DatabaseData
    var qnet: DeepQNetwork
    var actionsArray: [Action]
    
    func a() {
        print("\(+1)")
        do {
            qnet.storeAndDelete(id: data.id, state: try MLMultiArray(data.state), action: data.action, reward: 1.0, nextState: try MLMultiArray(data.state))
        } catch {
            
        }
    }
    
    func b() {
        print("\(0)")
        do {
            qnet.storeAndDelete(id: data.id, state: try MLMultiArray(data.state), action: data.action, reward: 0.0, nextState: try MLMultiArray(data.state))
        } catch {
            
        }
    }
    func c() {
        print("\(-1)")
        do {
            qnet.storeAndDelete(id: data.id, state: try MLMultiArray(data.state), action: data.action, reward: -1.0, nextState: try MLMultiArray(data.state))
        } catch {
            
        }
    }
    
    func getActionDescription(_ id: Int) -> String {
        for a in actionsArray {
            if a.id == id {
                return a.description
            }
        }
        return "No Description"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("ID \(String(data.id))")
                    .font(.title)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("Action")
                    Text(getActionDescription(data.action))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Brightness")
                    Text(String(format: "%.1f", data.state[0]))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Battery")
                    Text(String(format: "%.1f", data.state[1]))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Clock")
                    Text("\(Int(data.state[2])): \(Int(data.state[3])). \(Int(data.state[4]))")
                }.font(.subheadline)
                .foregroundColor(.secondary)

                Divider()
                HStack (
                    alignment: .top,
                    spacing: 50
                ) {
                    Button("+1", action: a)
                    Button("0", action: b)
                    Button("-1", action: c)
                }
            }
            .padding()
        }
        .navigationTitle(String(data.id))
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct Detail_Previews: PreviewProvider {
//    static var previews: some View {
//        Detail(data: databaseDataApp[0])
//    }
//}
