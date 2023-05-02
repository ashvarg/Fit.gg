//
//  DatabaseProtocol.swift
//  FIT3178-W03-Lab
//
//  Created by Vincent Wijaya on 21/3/2023.
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
    func onUserChange(change: DatabaseChange, user: User)
    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero])
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero])
}

protocol DatabaseProtocol: AnyObject {
    func cleanUp()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addSuperhero(name: String, abilities: String, universe: Universe) -> Superhero
    func deleteSuperhero(hero: Superhero)
    
    var team: Team? {get set}
    var user: User? {get set}
    
    func addTeam(teamName: String) -> Team
    func deleteTeam(team: Team)
    func addHeroToTeam(hero: Superhero, team: Team) -> Bool
    func removeHeroFromTeam(hero: Superhero, team: Team)
    
    func signInWith(email: String, password: String) -> Bool
    func signUpWith(email: String, password: String) -> Bool
    func signOut()
}
