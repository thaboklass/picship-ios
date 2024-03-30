//
//  EncodableExtension.swift
//  Majeshi
//
//  Created by Thabo David Klass on 24/05/2018.
//  Copyright © 2018 Spreebie, Inc. All rights reserved.
//

import Foundation

enum MyError: Error {
    case encodingError
}

extension Encodable {
    func toJson(excluding keys: [String] = [String]()) throws -> [String: Any] {
        
        let objectData = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: objectData, options: [])
        guard var json = jsonObject as? [String: Any] else { throw MyError.encodingError }
        
        for key in keys {
            json[key] = nil
        }
        
        return json
    }
}
