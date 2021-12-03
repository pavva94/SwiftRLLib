/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Storage for model data.
*/

import Foundation


let databasePath: String = "database.json"

public func loadDatabase() -> [DatabaseData] {
    var data: Data
    defaultLogger.log("\(databasePath)")
    let fileManager = FileManager.default
    do {

        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(databasePath)
//        defaultLogger.log(fileURL)
    
        data = try Data(contentsOf: fileURL)
    } catch {
        defaultLogger.log("Couldn't load database from main bundle: \(error.localizedDescription)")
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
        fatalError("Couldn't parse \(databasePath) as \([DatabaseData].self):\n\(error)")
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
    defaultLogger.log("database SAVED")
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
           defaultLogger.error("Error during the reset of database \(error.localizedDescription)")
       }
}

/// Delete data to the database using ID
func deleteFromDataset(id: Int) {
    let databaseData: [DatabaseData] = loadDatabase()
    
    let newDatabaseData = databaseData.filter { $0.id != id }
    
    saveDatabase(data: newDatabaseData)
}

/// Add data to the database
func addDataToDatabase(_ data: DatabaseData) {
    var databaseData: [DatabaseData] = loadDatabase()

    databaseData.append(data)
    
    saveDatabase(data: databaseData)
}
