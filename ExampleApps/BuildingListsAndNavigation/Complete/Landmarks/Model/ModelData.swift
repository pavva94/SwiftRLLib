/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Storage for model data.
*/

import Foundation

var landmarks: [Landmark] = load("landmarkData.json")

func load<T: Decodable>(_ filename: String) -> T {
    var data: Data
    print(filename)
    let fileManager = FileManager.default
    do {

        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(filename)
        print(fileURL)
    
        data = try Data(contentsOf: fileURL)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func loadDatabase(_ filename: String) -> [DatabaseData] {
    var data: Data
    print(filename)
    let fileManager = FileManager.default
    do {

        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(filename)
        print(fileURL)
    
        data = try Data(contentsOf: fileURL)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    if data.count == 0 {
        let temp: [DatabaseData] = []
        return temp
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode([DatabaseData].self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \([DatabaseData].self):\n\(error)")
    }
}


func SaveToFile(data: [DatabaseData]){
    let fileManager = FileManager.default

    do {

        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(databasePath)
    
        let encoder = JSONEncoder()

            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL)
        } catch {
            fatalError("Couldn't write JSON:\n\(error)")
        }
    print("database SAVED")
}

func resetDatabase() {
    let fileManager = FileManager.default
    let data: [DatabaseData] = []
    do {
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(databasePath)
        let encoder = JSONEncoder()

        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL)
       } catch {
         print(error)
       }
}


func manageDatabase(_ data: DatabaseData) {
//    databaseData = load(databasePath)
    
    
    databaseData.append(data)
    
    SaveToFile(data: databaseData)
    
    
//    var databaseDataCheck: [DatabaseData] = load(databasePath)
//    print(databaseDataCheck)
}
