//
//  User-extension.swift
//  Crouded
//
//  Created by Richard Fickling on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

import Foundation

extension User {
    
    class func enter(email: String, success: (User) -> (), failure: (NSError) -> ()) {
        return success(User(email: email))
    }
    
    func getMyRaces(completion: ([Race], NSError?) -> ()) {
        
        let db = (UIApplication.sharedApplication().delegate as AppDelegate).database
        
        let query = db.viewNamed("viewByType").createQuery()
        query.keys = ["race"]
        
        var error: NSError?
        let result = query.run(&error)
        
        var myRaces: [Int] = []
        while let row = result?.nextRow()?.value as? [String: AnyObject] {
            if let users = row["users"] as? [[String: AnyObject]] {
                for user in users {
                    if let email = user["email"] as? String {
                        if email == self.email {
                            myRaces.append(row["esri_id"]! as Int)
                        }
                    }
                }
            }
        }
        
        if Races.sharedRaces().allRaces != nil {
            return completion(
                (Races.sharedRaces().allRaces as [Race]).filter({ race in
                    return (find(myRaces, Int(race.raceID)) != nil)
                }
                ), nil)
        } else {
            Races.sharedRaces().findRacesWithCompletion({ races, err in
                if err != nil { return completion([], err) }
                return completion((races as [Race]).filter({ race in
                    return (find(myRaces, Int(race.raceID)) != nil)
                    }
                    ), err)
            })
        }
    }
    
    func getNearbyRaces(completion: ([Race], NSError?) -> ()) {
        
        let db = (UIApplication.sharedApplication().delegate as AppDelegate).database
        
        let query = db.viewNamed("viewByType").createQuery()
        query.keys = ["race"]
        
        var error: NSError?
        let result = query.run(&error)
        
        var myRaces: [Int] = []
        while let row = result?.nextRow()?.value as? [String: AnyObject] {
            if let users = row["users"] as? [[String: AnyObject]] {
                for user in users {
                    if let email = user["email"] as? String {
                        if email == self.email {
                            myRaces.append(row["esri_id"]! as Int)
                        }
                    }
                }
            }
        }
        
        
        if Races.sharedRaces().allRaces != nil {
            return completion(
                (Races.sharedRaces().allRaces as [Race]).filter({ race in
                    return (find(myRaces, Int(race.raceID)) == nil)
                    }
                ), nil)
        } else {
            Races.sharedRaces().findRacesWithCompletion({ races, err in
                if err != nil { return completion([], err) }
                return completion((races as [Race]).filter({ race in
                    return (find(myRaces, Int(race.raceID)) == nil)
                    }
                    ), err)
            })
        }
    }
}