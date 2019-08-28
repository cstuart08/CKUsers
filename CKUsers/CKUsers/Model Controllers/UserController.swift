//
//  UserController.swift
//  CKUsers
//
//  Created by Apps on 8/28/19.
//  Copyright © 2019 Apps. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    // MARK: - PROPERTIES
    // Singleton
    static let shared = UserController()
    // S.O.T
    var currentUser: User?
    // Public database
    let dataBase = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD
    
    // Create
    func createUser(email: String, username: String, petName: String, completion: @escaping (Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserRefID, error) in
            if let error = error {
                print("Error fetching User: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let appleUserRefID = appleUserRefID else { completion(false); return }
            
            let appleUserRef = CKRecord.Reference(recordID: appleUserRefID, action: .deleteSelf)
            
            let user = User(email: email, username: username, petName: petName, appleUserRef: appleUserRef)
            
            let userRecord = CKRecord(user: user)
            
            self.dataBase.save(userRecord, completionHandler: { (record, error) in
                if let error = error {
                    print("Error saving user: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let record = record else { completion(false); return }
                //Setting this user to the currentUser gaurantees we save the user in the database before locally saving. Also saves us from calling fetch after creating new user.
                guard let user = User(ckRecord: record) else { return }
                self.currentUser = user
                
                completion(true)
            })
        }
    }
    
    // Read
    func fetchUser(completion: @escaping (_ success: Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserRefID, error) in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let appleUserRefID = appleUserRefID else { completion(false); return }
            let appleUserRef = CKRecord.Reference(recordID: appleUserRefID, action: .deleteSelf)
            
            // What we want back: appleUserReference of the current logged in user.
            let predicate = NSPredicate(format: "appleUserRef == %@", appleUserRef)
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            self.dataBase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("Error fetching User: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let records = records, //unwrap array of records
                    let firstRecord = records.first, // Get the first record (hopefully only)
                    let currentUser = User(ckRecord: firstRecord) else { completion(false); return }
                
                self.currentUser = currentUser // Sets the S.O.T
                completion(true)
            })
        }
    }
}
