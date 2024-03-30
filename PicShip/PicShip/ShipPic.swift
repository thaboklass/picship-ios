//
//  ShipPic.swift
//  PicShip
//
//  Created by Thabo David Klass on 03/07/2019.
//  Copyright © 2019 Open Beacon. All rights reserved.
//

import Foundation

/// The User class
class ShipPic {
    /// A private holder for the key
    private var _shipPicID: String? = nil
    
    /// A private holder for the key
    private var _mainKey: String? = nil
    
    /// A private holder for the key
    private var _videoFileURL: String? = nil
    
    /// A private holder for the key
    private var _imageFileURL: String? = nil
    
    /// A private holder for the key
    private var _title: String? = nil
    
    /// A private holder for the key
    private var _createdAt: Int? = nil
    
    /// A private holder for the key
    private var _dueAt: Int? = nil
    
    /// A private holder for the key
    private var _isVideo: Bool? = nil
    
    /// A private holder for the key
    private var _isDealtWith: Bool? = nil
    
    /// A private holder for the key
    private var _contactUserID: String? = nil
    
    /// A private holder for the key
    private var _contactName: String? = nil
    
    /// The key getter
    var shipPicID: String? {
        return _shipPicID
    }
    
    /// The key getter
    var mainKey: String? {
        return _mainKey
    }
    
    /// The key getter
    var videoFileURL: String? {
        return _videoFileURL
    }
    
    /// The key getter
    var imageFileURL: String? {
        return _imageFileURL
    }
    
    /// The key getter
    var title: String? {
        return _title
    }
    
    /// The key getter
    var createdAt: Int? {
        return _createdAt
    }
    
    /// The key getter
    var dueAt: Int? {
        return _dueAt
    }
    
    /// The key getter
    var isVideo: Bool? {
        return _isVideo
    }
    
    /// The key getter
    var isDealtWith: Bool? {
        return _isDealtWith
    }
    
    /// The key getter
    var contactUserID: String? {
        return _contactUserID
    }
    
    /// The key getter
    var contactName: String? {
        return _contactName
    }
    
    
    /// A constuctor that takes the key and a dictionary that contains
    /// user data
    init(shipPicID: String, mainKey: String, shipPicData: Dictionary<String, AnyObject>) {
        _shipPicID = shipPicID
        
        _mainKey = mainKey
        
        if let videoFileURL = shipPicData["videoFileURL"] as? String {
            _videoFileURL = videoFileURL
        }
        
        if let imageFileURL = shipPicData["imageFileURL"] as? String {
            _imageFileURL = imageFileURL
        }
        
        if let title = shipPicData["title"] as? String {
            _title = title
        }
        
        if let createdAt = shipPicData["createdAt"] as? Int {
            _createdAt = createdAt
        }
        
        if let dueAt = shipPicData["dueAt"] as? Int {
            _dueAt = dueAt
        }
        
        if let isVideo = shipPicData["isVideo"] as? Bool {
            _isVideo = isVideo
        }
        
        if let isDealtWith = shipPicData["isDealtWith"] as? Bool {
            _isDealtWith = isDealtWith
        }
        
        if let contactUserID = shipPicData["contactUserID"] as? String {
            _contactUserID = contactUserID
        }
        
        if let contactName = shipPicData["contactName"] as? String {
            _contactName = contactName
        }
    }
}
