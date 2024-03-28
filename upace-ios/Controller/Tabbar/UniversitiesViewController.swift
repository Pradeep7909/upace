//
//  UniversitiesViewController.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class UniversitiesViewController: UIViewController {
    
    var databaseRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        LOG("\(type(of: self)) viewDidLoad")
        setupFirebase()
    }

    func setupFirebase() {
        // Configure Firebase app
        guard FirebaseApp.app() != nil else {
            print("Firebase app is not configured.")
            return
        }
        
        // Reference the "actions" child node
        databaseRef = Database.database().reference().child("actions")
        
        // Observer for new child nodes added
        databaseRef.observe(.childAdded) { snapshot in
            if let key = snapshot.key as? String, let value = snapshot.value {
                print("New child added:")
                print("Key: \(key), Value: \(value)")
            } else {
                print("No data or key found for the new child.")
            }
        }
        
        // Observer for updated nodes
        databaseRef.observe(.childChanged) { snapshot in
            if let key = snapshot.key as? String, let value = snapshot.value {
                print("Node updated:")
                print("Key: \(key), Value: \(value)")
            } else {
                print("No data or key found for the updated node.")
            }
        }
        
        // Observer for deleted nodes
        databaseRef.observe(.childRemoved) { snapshot in
            if let key = snapshot.key as? String, let value = snapshot.value {
                print("Node deleted:")
                print("Key: \(key), Value: \(value)")
            } else {
                print("No data or key found for the deleted node.")
            }
        }
    }

}

