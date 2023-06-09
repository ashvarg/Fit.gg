//
//  FirebaseController.swift
//  Fit.GG
//
//  Created by Ashwin George on 11/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseController: NSObject, FireDatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var user: User?
    
    var authController: Auth
    var database: Firestore
    var usersRef: CollectionReference?
    var heroesRef: CollectionReference?
    var teamsRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        
        super.init()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    

    
    func addUser(userId: String) -> User {
        let user = User()
        user.id = userId
        print(userId)
        if let _ = usersRef?.document(userId).setData(["team" : ""]) {
            print("USER CREATED SUCCESSFULLY")
        }
        
        return user
    }
    

    
    

    
    func cleanUp() {
        // Do nothing
    }
    
    // MARK: - Firebase Controller Specific Methods
    
    func setupUserListener() {
        usersRef = database.collection("users")
        
        guard let userId = currentUser?.uid else {
            return
        }
        
        usersRef?.document(userId).addSnapshotListener { (querySnapshot, error) in
            
            guard let _ = querySnapshot else {
                print("Error fetching users: \(String(describing: error))")
                return
            }
            
        }
    }
    
    
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot) {
        user = User()
        
        guard let user = user else {
            return
        }
        
        user.id = snapshot.documentID
    }
    
    
    // MARK: - Authentication
    
    func signInWith(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            
            if let user = authResult?.user, error == nil {
                strongSelf.currentUser = user
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func signUpWith(email: String, password: String) -> Bool {
        var result = false
        DispatchQueue.main.async {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let user = authResult?.user, error == nil {
                    self.currentUser = user
                    print("user created successfuly")
                    result = true
                }
            }
        }
        
        return result
    }
    
    
    func signOut() {
        do {
           try Auth.auth().signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
