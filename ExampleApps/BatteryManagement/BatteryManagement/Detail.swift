//
//  Detail.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL
import CoreML
import MapKit


struct Detail: View {
    var data: DatabaseData
    var qnet: DeepQNetwork
    var actionsArray: [Action]
    
//    func a() {
//        print("\(+1)")
//        do {
//            qnet.storeAndDelete(id: data.id, state: try MLMultiArray(data.state), action: data.action, reward: 1.0, nextState: try MLMultiArray(data.state))
//        } catch {
//
//        }
//    }
    
//    func b() {
//        print("\(0)")
//        do {
//            qnet.storeAndDelete(id: data.id, state: try MLMultiArray(data.state), action: data.action, reward: 0.0, nextState: try MLMultiArray(data.state))
//        } catch {
//            
//        }
//    }
//    func c() {
//        print("\(-1)")
//        do {
//            qnet.storeAndDelete(id: data.id, state: try MLMultiArray(data.state), action: data.action, reward: -1.0, nextState: try MLMultiArray(data.state))
//        } catch {
//            
//        }
//    }
//    
    func getActionDescription(_ id: Int) -> String {
        for a in actionsArray {
            if a.id == id {
                return a.description
            }
        }
        return "No Description"
    }
    
    func openMap() -> Void {
        let latitude: CLLocationDegrees = data.state[0]
        let longitude: CLLocationDegrees = data.state[1]
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Selected Position"
        mapItem.openInMaps(launchOptions: options)
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
                    Text("State -> Coordinates")
                    Text(String(format: "%.1f", data.state[0]))
                    Text(String(format: "%.1f", data.state[1]))
                    Button("Open in Maps", action: openMap)
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Battery")
                    Text(String(format: "%.1f", data.state[2]))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Clock")
                    Text("\(Int(data.state[3])): \(Int(data.state[4])). \(Int(data.state[5]))")
                }.font(.subheadline)
                .foregroundColor(.secondary)
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> LowPowerMode")
                    Text("\(Int(data.state[6]))")
                }.font(.subheadline)
                .foregroundColor(.secondary)

//                Divider()
                
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
                    Text("Reward")
                    Text(String(format: "%.1f", data.reward))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Coordinates")
                    Text(String(format: "%.1f", data.nextState[0]))
                    Text(String(format: "%.1f", data.nextState[1]))
                    Button("Open in Maps", action: openMap)
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Battery")
                    Text(String(format: "%.1f", data.nextState[2]))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Clock")
                    Text("\(Int(data.nextState[3])): \(Int(data.nextState[4]))")
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                
                
                
//                HStack (
//                    alignment: .top,
//                    spacing: 10
//                ) {
//                    Text("State -> LowPowerMode")
//                    Text("\(Int(data.nextState[5]))")
//                }.font(.subheadline)
//                .foregroundColor(.secondary)
                
                
//                HStack (
//                    alignment: .top,
//                    spacing: 50
//                ) {
//                    Button("+1", action: a)
//                    Button("0", action: b)
//                    Button("-1", action: c)
//                }
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


