//
//  DataManager.swift
//  SwiftRL
//
//  Created by Alessandro Pavesi on 12/11/21.
//

import Foundation

/// Data Manager for open, add, save files
public class DataManager {
    
    /// Load a file with DatabaseData
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
    
    /// Save a file with DatabaseData
    func saveDatabase(data: [DatabaseData], path: String) {
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

    /// Remove the first element, like a FIFO
    func removeFirstDataFromDatabase(_ path: String) {
        let databaseData: [DatabaseData] = loadDatabase(path)
        
        let newDatabaseData = Array(databaseData.suffix(from: 1))
        
        saveDatabase(data: newDatabaseData, path: path)
    }

    /// Add data to the database
    func addDataToDatabase(_ data: DatabaseData, _ path: String) {
        var databaseData: [DatabaseData] = loadDatabase(path)

        databaseData.append(data)
        
        saveDatabase(data: databaseData, path: path)
    }

    /// Utility function to copy files from the Bundle to the App Documents
    public func copyFilesFromBundleToDocumentsFolderWith(fileExtension: String) {
        if let resPath = Bundle.main.resourcePath {
            do {
                let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                var filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
                
                // Remove the Original compiled model
                if fileExtension == ".mlmodelc" {
                    if let indexAppleModelc = filteredFiles.firstIndex(of: "RLModel.mlmodelc") {
                        filteredFiles.remove(at: indexAppleModelc)
                    }
                }
                for fileName in filteredFiles {
                    if let documentsURL = documentsURL {
                        let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                        let destURL = documentsURL.appendingPathComponent(fileName)
                        do {
                            try FileManager.default.copyItem(at: sourceURL, to: destURL)
                            defaultLogger.log("\(fileName) copied.")
                            
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
}

public let dataManager = DataManager()
