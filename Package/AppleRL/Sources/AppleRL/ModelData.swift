/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Storage for model data.
*/

import Foundation

/// Database used to check all the action done by the agent
let databasePath: String = "database.json"

/// Permanent store of the buffer
let bufferPath: String = "buffer.json"

public func loadDatabase(_ path: String) -> [DatabaseData] {
    var data: Data
    defaultLogger.log("\(path)")
    let fileManager = FileManager.default
    do {

        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileURL = documentDirectory.appendingPathComponent(path)
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
        let finalData = try decoder.decode([DatabaseData].self, from: data)
        defaultLogger.log("Database \(path) count: \(finalData.count)")
        return finalData
    } catch {
        fatalError("Couldn't parse \(path) as \([DatabaseData].self):\n\(error)")
    }
}


func saveDatabase(data: [DatabaseData], path: String){
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
    defaultLogger.log("database SAVED")
}

/// Reset the database to empty
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
           defaultLogger.error("Error during the reset of database \(error.localizedDescription)")
       }
    defaultLogger.log("Reset of database done \(path)")
}

/// Delete data to the database using ID
func deleteFromDataset(id: Int, path: String) {
    let databaseData: [DatabaseData] = loadDatabase(path)
    
    let newDatabaseData = databaseData.filter { $0.id != id }
    
    saveDatabase(data: newDatabaseData, path: path)
}

/// Add data to the database
func addDataToDatabase(_ data: DatabaseData, _ path: String) {
    var databaseData: [DatabaseData] = loadDatabase(path)

    databaseData.append(data)
    
    saveDatabase(data: databaseData, path: path)
}

public func copyFilesFromBundleToDocumentsFolderWith(fileExtension: String) {
    if let resPath = Bundle.main.resourcePath {
        do {
            let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            var filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
            
            // Remove the Original compiled model 
            if fileExtension == ".mlmodelc" {
                if let indexAppleModelc = filteredFiles.firstIndex(of: "AppleRLModel.mlmodelc") {
                    filteredFiles.remove(at: indexAppleModelc)
                }
            }
            for fileName in filteredFiles {
                if let documentsURL = documentsURL {
                    let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                    let destURL = documentsURL.appendingPathComponent(fileName)
                    do {
                        try FileManager.default.copyItem(at: sourceURL, to: destURL)
                        
                    } catch {
                        defaultLogger.error("Error during the copy of files \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            defaultLogger.error("Error during move of files: \(error.localizedDescription)")
        }
    }
}
