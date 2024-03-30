//
//  Comment.swift
//  Kascada
//
//  Created by Thabo David Klass on 16/11/2017.
//  Copyright © 2017 Open Beacon. All rights reserved.
//

import Foundation

/// The Comment class
class Comment {
    /// A private holder for the key
    private var _key: String? = nil
    
    /// A private holder for the comment
    private var _comment: String? = nil
    
    /// A private holder for the creation timestamp
    private var _creationAt: Int? = nil
    
    /// A private holder for the update timestamp
    private var _updatedAt: Int? = nil
    
    /// A private holder for the the user who created the Kascade
    private var _user: String? = nil
    
    /// The key getter
    var key: String? {
        return _key
    }
    
    /// The caption getter
    var comment: String? {
        return _comment
    }
    
    /// The creationAt getter
    var creationAt: Int? {
        return _creationAt
    }
    
    /// The updatedAt getter
    var updatedAt: Int? {
        return _updatedAt
    }
    
    /// The user getter
    var user: String? {
        return _user
    }
    
    // The user's full name
    var userFullName: String? = nil
    
    /// The user's profile picture file name
    var userProfilePictureFileName: String? = nil
    
    /// A constuctor that takes the key and a dictionary that contains
    /// kascade data
    init(key: String, commentData: Dictionary<String, AnyObject>) {
        _key = key
        
        if let comment = commentData["commentText"] as? String {
            _comment = comment
        }
        
        if let creationAt = commentData["createdAt"] as? Int {
            _creationAt = creationAt
        }
        
        if let updatedAt = commentData["updatedAt"] as? Int {
            _updatedAt = updatedAt
        }
        
        if let user = commentData["user"] as? String {
            _user = user
        }
    }
}
