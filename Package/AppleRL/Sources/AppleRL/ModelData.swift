/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Storage for model data.
*/

import Foundation


let databasePath: String = "database.json"

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


func saveDatabase(data: [DatabaseData]){
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

/// Reset the database to empty
public func resetDatabase() {
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

/// Delete data to the database using ID
func deleteFromDataset(id: Int) {
    let databaseData: [DatabaseData] = loadDatabase(databasePath)
    
    let newDatabaseData = databaseData.filter { $0.id != id }
    
    saveDatabase(data: newDatabaseData)
}

/// Add data to the database
func addDataToDatabase(_ data: DatabaseData) {
    var databaseData: [DatabaseData] = loadDatabase(databasePath)

    databaseData.append(data)
    
    saveDatabase(data: databaseData)
}
