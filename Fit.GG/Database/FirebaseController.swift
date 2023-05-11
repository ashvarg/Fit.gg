//
//  FirebaseController.swift
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseController: NSObject, DatabaseProtocol {
    
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
        if let userRef = usersRef?.document(userId).setData(["team" : ""]) {
            print("USER CREATED SUCCESSFULLY")
        }
        
        return user
    }
    
//        if let teamRef = teamsRef?.addDocument(data: ["name" : teamName, "heroes" : []]) {
//            team.id = teamRef.documentID
//            print("TEAM CREATED SUCCESSFULLY")
//        }
//
//        return team
//    }
    
    

    
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
            
            guard let userSnapshot = querySnapshot else {
                print("Error fetching users: \(String(describing: error))")
                return
            }
            
//            self.parseUserSnapshot(snapshot: userSnapshot as! QueryDocumentSnapshot)
            
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
    
    func signInWith(email: String, password: String) -> Bool {
        var result = false
        DispatchQueue.main.async {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let user = authResult?.user, error == nil {
                    strongSelf.currentUser = user
                    result = true
                }
            }
        }
        
        return result
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
