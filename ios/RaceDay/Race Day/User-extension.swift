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
        /*APIManager.post("/user", params: ["email": email],
            success: { data in
                let user = User(email: email)
                return success(user)
            },
            failure: failure
        )*/
        return success(User(email: email))
    }
    
    func getMyRaces(completion: ([Race], NSError?) -> ()) {
        if Races.sharedRaces().allRaces != nil {
            return completion(Races.sharedRaces().allRaces as [Race], nil)
        } else {
            Races.sharedRaces().findRacesWithCompletion({ races, err in
                return completion(races as [Race], err)
            })
        }
    }
    
    func getNearbyRaces(completion: ([Race], NSError?) -> ()) {
        if Races.sharedRaces().allRaces != nil {
            return completion(Races.sharedRaces().allRaces as [Race], nil)
        } else {
            Races.sharedRaces().findRacesWithCompletion({ races, err in
                return completion(races as [Race], err)
            })
        }
    }
}