/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing the details for a landmark.
*/

import SwiftUI
import CoreML

struct LandmarkDetail: View {
    var landmark: DatabaseData
    
    func a() {
        print(+1)
        do {
            qnet.store(state: try MLMultiArray(landmark.state), action: landmark.action, reward: 1.0, nextState: try MLMultiArray(landmark.state))
            
            
        } catch {
            
        }
    }
    
    func b() {
        print(0)
        do {
        qnet.store(state: try MLMultiArray(landmark.state), action: landmark.action, reward: 0.0, nextState: try MLMultiArray(landmark.state))
        } catch {
            
        }
    }
    func c() {
        print(-1)
        do {
        qnet.store(state: try MLMultiArray(landmark.state), action: landmark.action, reward: -1.0, nextState: try MLMultiArray(landmark.state))
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
                    Text("State -> Brightness")
                    Text("State -> Battery")
                    Text("State -> Ambient Light")
                }
                HStack (
                    alignment: .top,
                    spacing: 10
                ) {
                    Text(String(landmark.action))
//                    Text(landmark.state.description)
                    Text(String(format: "%.1f", landmark.state[0]))
                    Text(String(format: "%.1f", landmark.state[1]))
                    Text(String(format: "%.1f", landmark.state[2]))
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Divider()

//                Text("About \(landmark.description)")
//                    .font(.title2)
//                Text(String(format: "%.1f", landmark.state))
                
                Button("+1", action: a)
                Button("0", action: b)
                Button("-1", action: c)
            }
            .padding()
        }
        .navigationTitle(String(landmark.id))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LandmarkDetail_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkDetail(landmark: databaseData[0])
    }
}
