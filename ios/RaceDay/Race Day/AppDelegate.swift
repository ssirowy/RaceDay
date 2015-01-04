//
//  AppDelegate.swift
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var database: CBLDatabase!
    private let kSyncUrl = NSURL(string: "http://104.131.187.45:4984/default")
    private var _pull: CBLReplication!
    private var _push: CBLReplication!
    private var _lastSyncError: NSError?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        if !setupDatabase() {
            return false
        }
        startSync()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func setupDatabase() -> Bool {
        // Step 3: Setup 'kitchen-sync' database
        var error: NSError?
        database = CBLManager.sharedInstance().databaseNamed("default", error: &error)
        if database == nil {
            NSLog("Cannot get kitchen-sync database with error: %@", error!)
            return false
        }
        
        database.viewNamed("viewByType").setMapBlock({ doc, emit in
            if let type = doc["type"] as? String {
                emit(type, doc)
            }
        }, version: "1.0")
        
        
        
        return true
    }
    
    private func startSync() {
        if kSyncUrl == nil {
            return
        }
        
        _pull = database.createPullReplication(kSyncUrl)
        _push = database.createPushReplication(kSyncUrl)
        
        _pull.continuous = true
        _push.continuous = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replicationProgress:",
            name: kCBLReplicationChangeNotification, object: _pull)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replicationProgress:",
            name: kCBLReplicationChangeNotification, object: _push)
        
        _pull.start()
        _push.start()
    }
    
    func replicationProgress(notification: NSNotification) {
        if _pull.status == CBLReplicationStatus.Active ||
            _push.status == CBLReplicationStatus.Active {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        let error = _pull.lastError ?? _push.lastError
        if error != _lastSyncError {
            _lastSyncError = error
            if error != nil {
                NSLog("Replication Error: %@", error!)
            }
        }
    }

}

