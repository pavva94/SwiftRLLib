/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing the details for a landmark.
*/

import SwiftUI
import CoreML
import AppleRL

struct LandmarkDetail: View {
    var landmark: DatabaseData
    
    func a() {
        defaultLogger.log("\(+1)")
        do {
            qnet.storeAndDelete(id: landmark.id, state: try MLMultiArray(landmark.state), action: landmark.action, reward: 1.0, nextState: try MLMultiArray(landmark.state))
        } catch {
            
        }
    }
    
    func b() {
        defaultLogger.log("\(0)")
        do {
            qnet.storeAndDelete(id: landmark.id, state: try MLMultiArray(landmark.state), action: landmark.action, reward: 0.0, nextState: try MLMultiArray(landmark.state))
        } catch {
            
        }
    }
    func c() {
        defaultLogger.log("\(-1)")
        do {
            qnet.storeAndDelete(id: landmark.id, state: try MLMultiArray(landmark.state), action: landmark.action, reward: -1.0, nextState: try MLMultiArray(landmark.state))
        } catch {
            
        }
    }

    var body: some View {
        ScrollView {
//            MapView(coordinate: landmark.locationCoordinate)
//                .ignoresSafeArea(edges: .top)
//                .frame(height: 300)

//            CircleImage(image: landmark.image)
//                .offset(y: -130)
//                .padding(.bottom, -130)

            VStack(alignment: .leading) {
                Text("ID \(String(landmark.id))")
                    .font(.title)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("Action")
                    Text(String(landmark.action))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Brightness")
                    Text(String(format: "%.1f", landmark.state[0]))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Battery")
                    Text(String(format: "%.1f", landmark.state[1]))
                }.font(.subheadline)
                .foregroundColor(.secondary)
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text("State -> Ambient Light")
                    Text(String(format: "%.1f", landmark.state[2]))
                }.font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

//                Text("About \(landmark.description)")
//                    .font(.title2)
//                Text(String(format: "%.1f", landmark.state))
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
        .navigationTitle(String(landmark.id))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LandmarkDetail_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkDetail(landmark: databaseDataApp[0])
    }
}
