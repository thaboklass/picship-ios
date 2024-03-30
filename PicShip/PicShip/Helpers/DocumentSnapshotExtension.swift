//
//  DocumentSnapshotExtension.swift
//  Majeshi
//
//  Created by Thabo David Klass on 24/05/2018.
//  Copyright © 2018 Spreebie, Inc. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension DocumentSnapshot {
    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) throws  -> T {
        
        var documentJson = data()
        if includingId {
            documentJson!["id"] = documentID
        }
        
        let documentData = try JSONSerialization.data(withJSONObject: documentJson, options: [])
        let decodedObject = try JSONDecoder().decode(objectType, from: documentData)
        
        return decodedObject
    }
}
