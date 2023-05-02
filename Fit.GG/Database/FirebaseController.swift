//
//  FirebaseController.swift
//  FIT3178-W03-Lab
//
//  Created by Vincent Wijaya on 6/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var heroList: [Superhero]
    var team: Team?
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
        heroList = [Superhero]()
        team = Team()
        
        super.init()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .team || listener.listenerType == .user || listener.listenerType == .all {
            listener.onTeamChange(change: .update, teamHeroes: team!.heroes)
        }
        if listener.listenerType == .heroes || listener.listenerType == .all {
            listener.onAllHeroesChange(change: .update, heroes: heroList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addSuperhero(name: String, abilities: String, universe: Universe) -> Superhero {
        let hero = Superhero()
        hero.name = name
        hero.abilities = abilities
        hero.universe = universe.rawValue
        
        do {
            if let heroRef = try heroesRef?.addDocument(from: hero) {
                hero.id = heroRef.documentID
            }
        }
        catch {
            print("Failed to serialise hero")
        }
        
        return hero
    }
    
    func addTeam(teamName: String) -> Team {
        let team = Team()
        team.name = teamName
        team.heroes = []
        
        do {
            if let teamRef = try teamsRef?.addDocument(from: team) {
                team.id = teamRef.documentID
                print("TEAM CREATED SUCCESSFULLY")
            }
        }
        catch {
            print("Failed to serialise team")
        }
        
        return team
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
    
    func addHeroToTeam(hero: Superhero, team: Team) -> Bool {
        guard let heroID = hero.id, let teamID = team.id, team.heroes.count < 6 else {
            return false
        }
        
        if let newHeroRef = heroesRef?.document(heroID) {
            teamsRef?.document(teamID).updateData(
                ["heroes" : FieldValue.arrayUnion([newHeroRef])]
            )
            
            return true
        }
        
        return false
    }
    
    func deleteSuperhero(hero: Superhero) {
        if let heroID = hero.id {
            teamsRef?.document(heroID).delete()
        }
    }
    
    func deleteTeam(team: Team) {
        if let teamID = team.id {
            teamsRef?.document(teamID).delete()
        }
    }
    
    func removeHeroFromTeam(hero: Superhero, team: Team) {
        if team.heroes.contains(hero), let teamID = team.id, let heroID = hero.id {
            if let removedHeroRef = heroesRef?.document(heroID) {
                teamsRef?.document(teamID).updateData(
                    ["heroes" : FieldValue.arrayRemove([removedHeroRef])]
                )
            }
        }
    }
    
    func cleanUp() {
        // Do nothing
    }
    
    // MARK: - Firebase Controller Specific Methods
    
    func getHeroByID(_ id: String) -> Superhero? {
        for hero in heroList {
            if hero.id == id {
                return hero
            }
        }
        
        return nil
    }
    
    func setupHeroListener() {
        heroList = [Superhero]()
        heroesRef = database.collection("superheroes")
        heroesRef?.addSnapshotListener() {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseHeroesSnapshot(snapshot: querySnapshot)
            print("parsed heroes")
            
            print("Setting up team listener")
            self.setupTeamListener()
            
        }
    }
    
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
    
    func setupTeamListener() {
        teamsRef = database.collection("teams")
        
        guard let teamName = currentUser?.uid else {
            print("uid doesn't exist for some reason")
            return
        }
        
        print("teamName")
        teamsRef?.whereField("name", isEqualTo: teamName).addSnapshotListener {
            (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot, let teamSnapshot = querySnapshot.documents.first else {
                print("Error fetching teams: \(String(describing: error))")
                return
            }
            
            self.parseTeamSnapshot(snapshot: teamSnapshot)
            
            print("got here")
            print("Setting up user listener")
            self.setupUserListener()
            
        }
    }
    
    func parseHeroesSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedHero: Superhero?
            
            do {
                parsedHero = try change.document.data(as: Superhero.self)
            }
            catch {
                print("Unable to decode hero. Is the hero malformed?")
                return
            }
            
            guard let hero = parsedHero else {
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added {
                heroList.insert(hero, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                heroList[Int(change.newIndex)] = hero
            }
            else if change.type == .removed {
                heroList.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.heroes || listener.listenerType == ListenerType.all {
                listener.onAllHeroesChange(change: .update, heroes: heroList)
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
    
    func parseTeamSnapshot(snapshot: QueryDocumentSnapshot) {
        team = Team()
        
        guard let team = team else {
            return
        }
        
        team.name = snapshot.data()["name"] as? String
        team.id = snapshot.documentID
        
        if let heroesRef = snapshot.data()["heroes"] as? [DocumentReference] {
            for reference in heroesRef {
                if let hero = getHeroByID(reference.documentID) {
                    team.heroes.append(hero)
                }
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.team || listener.listenerType == ListenerType.all {
                    listener.onTeamChange(change: .update, teamHeroes: team.heroes)
                }
            }
        }
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
                    self.setupUserTeamWith(user.uid)
                    print("user created successfuly")
                    result = true
                }
            }
        }
        
        return result
    }
    
    func setupUserTeamWith(_ userId: String) {
        let teamsRef = database.collection("teams")
        let teamRef = teamsRef.addDocument(data: ["name" : userId, "heroes" : []])
        
        database.collection("users").document(userId).setData(["team" : teamRef])
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
