//
//  FilesManager.swift
//  Landmarks
//
//  Created by Alessandro Pavesi on 25/11/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

let databasePath: String = "database.json"
var databaseData: [DatabaseData] = loadDatabase(databasePath) 
let fileManager = FilesManager()

class FilesManager {
    
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
        case fileNotExists
        case readingFailed
    }

    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func save(fileNamed: String, data: [DatabaseData]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(data)

        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        if fileManager.fileExists(atPath: url.absoluteString) {
            throw Error.fileAlreadyExists
        }
        do {
            try data.write(to: url)
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }

    func read(fileNamed: String) throws -> [DatabaseData] {
        guard let url = makeURL(forFileNamed: fileNamed) else {
           throw Error.invalidDirectory
        }
        
        guard fileManager.fileExists(atPath: url.absoluteString) else {
           throw Error.fileNotExists
        }

        let d: Data
        do {
            d = try Data(contentsOf: url)
        } catch {
           debugPrint(error)
           throw Error.readingFailed
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode([DatabaseData].self, from: d)
        } catch {
            fatalError("Couldn't parse \(databasePath) as \([DatabaseData].self):\n\(error)")
        }
    }

    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func addData(newData: DatabaseData) {
        do {
            var data = try read(fileNamed: databasePath)
            data.append(newData)
            try save(fileNamed: databasePath, data: data)
            
        } catch {
            fatalError("Error during writing of new Data on DB: \(error)")
        }
    }
    
}
