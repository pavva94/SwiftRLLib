/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Storage for model data.
*/

import Foundation


let databasePath: String = "database.json"

public func load<T: Decodable>(_ filename: String) -> T {
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

public func loadDatabase(_ filename: String) -> [DatabaseData] {
    var data: Data
    print(filename)
    let fileManager = FileManager.default
    do {

        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(filename)
        print(fileURL)
    
        data = try Data(contentsOf: fileURL)
    } catch {
        print("Couldn't load \(filename) from main bundle:\n\(error)")
        return []
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


func SaveToFile(data: [DatabaseData], path: String){
    let fileManager = FileManager.default

    do {

        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(path)
    
        let encoder = JSONEncoder()

            let jsonData = try encoder.encode(data)
            try jsonData.write(to: fileURL)
        } catch {
            fatalError("Couldn't write JSON:\n\(error)")
        }
    print("database SAVED")
}

public func resetDatabase(path: String) {
    let fileManager = FileManager.default
    let data: [DatabaseData] = []
    do {
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(path)
        let encoder = JSONEncoder()

        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL)
       } catch {
         print(error)
       }
}


func manageDatabase(_ data: DatabaseData, path: String) {
    var databaseData: [DatabaseData] = loadDatabase(path)
    
    
    databaseData.append(data)
    
    SaveToFile(data: databaseData, path: path)
    
    
//    var databaseDataCheck: [DatabaseData] = load(databasePath)
//    print(databaseDataCheck)
}
