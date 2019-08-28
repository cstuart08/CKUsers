//
//  User.swift
//  CKUsers
//
//  Created by Apps on 8/28/19.
//  Copyright © 2019 Apps. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    // MARK: - PROPERTIES
    let email: String
    let username: String
    let petName: String
    
        // MARK: - apple properties
        var ckRecordID: CKRecord.ID?  // Our custom User's recordID.
        let appleUserRef: CKRecord.Reference  // Reference to our cutom iCloud user.
    
    // MARK: - INITIALIZERS
    init(email: String, username: String, petName: String, appleUserRef: CKRecord.Reference) {
        self.email = email
        self.username = username
        self.petName = petName
        self.appleUserRef = appleUserRef
    }
}

extension User {
    convenience init?(ckRecord: CKRecord) {
        guard let email = ckRecord["email"] as? String,
            let username = ckRecord["username"] as? String,
            let petName = ckRecord["petname"] as? String,
            let appleUserRef = ckRecord["appleUserRef"] as? CKRecord.Reference else { return nil }
        
        self.init(email:email, username: username, petName: petName, appleUserRef: appleUserRef)
        ckRecordID = ckRecord.recordID
    }
}

extension CKRecord {
    
    convenience init(user: User) {
        // Use user's recordID if we have one, if we don't create a new one.
        let recordID = user.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        // Designated initializer
        self.init(recordType: "User", recordID: recordID)
        // Set the values
        self.setValue(user.username, forKey: "username")
        self.setValue(user.email, forKey: "email")
        self.setValue(user.petName, forKey: "petname")
        self.setValue(user.appleUserRef, forKey: "appleUserRef")
    }
}
