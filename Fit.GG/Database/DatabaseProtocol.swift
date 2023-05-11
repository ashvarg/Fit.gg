//
//  DatabaseProtocol.swift
//

import Foundation


enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case user
    case team
    case heroes
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
//    func onAuthChange(change: )
   

}

protocol DatabaseProtocol: AnyObject {
    func cleanUp()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    
    func signInWith(email: String, password: String) -> Bool
    func signUpWith(email: String, password: String) -> Bool
    func signOut()
   
}
