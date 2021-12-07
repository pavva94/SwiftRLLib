/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing the list of landmarks.
*/

import SwiftUI
import AppleRL

struct ContentView: View {
    var body: some View {
        LandmarkList().onAppear(perform: refreshData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



func refreshData() {
    databaseData = loadDatabase()
}
