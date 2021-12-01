/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A single row to be displayed in a list of landmarks.
*/

import SwiftUI
import AppleRL

//struct LandmarkRow: View {
//    var landmark: Landmark
//
//    var body: some View {
//        HStack {
////            landmark.image
////                .resizable()
////                .frame(width: 50, height: 50)
//            Text(landmark.name)
//
//            Spacer()
//        }
//    }
//}
//
//struct LandmarkRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            LandmarkRow(landmark: landmarks[0])
//            LandmarkRow(landmark: landmarks[1])
//        }
//        .previewLayout(.fixed(width: 300, height: 70))
//    }
//}

struct LandmarkRow: View {
    var landmark: DatabaseData

    var body: some View {
        HStack {
//            landmark.image
//                .resizable()
//                .frame(width: 50, height: 50)
            Text("ID")
            Text(String(landmark.id))
            Spacer()
        }
    }
}

struct LandmarkRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LandmarkRow(landmark: databaseData[0])
            LandmarkRow(landmark: databaseData[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}

