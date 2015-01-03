//
//  APIManager.swift
//  Milk
//
//  Created by Dick Fickling on 7/24/14.
//  Copyright (c) 2014 Honey Science Corporation. All rights reserved.
//

import Foundation

class APIManager {
    
    class func post(path: String, params: [String: AnyObject], success: (data: [String: AnyObject]!) -> (), failure: (NSError) -> ()) {
        var manager = AFHTTPRequestOperationManager()
        manager.requestSerializer = AFJSONRequestSerializer() as AFHTTPRequestSerializer
        request(manager, verb: "POST", path: path, params: params, success: success, failure: failure)
    }
    
    class func get(path: String, params: [String: AnyObject], success: (data: [String: AnyObject]!) -> (), failure: (NSError) -> ()) {
        var manager = AFHTTPRequestOperationManager()
        request(manager, verb: "GET", path: path, params: params, success: success, failure: failure)
    }
    
    class func request(manager: AFHTTPRequestOperationManager,
        verb: String,
        path: String,
        params: [String: AnyObject],
        success: (data: [String: AnyObject]!) -> (),
        failure: (NSError) -> ()) {
            func requestSuccess (op: AFHTTPRequestOperation!, data: AnyObject!) {
                // Cast as array if we can, otherwise cast as dictionary
                if var dataAsArray = data as? [AnyObject] {
                    success(data: ["data": dataAsArray])
                } else {
                    success(data: data as Dictionary)
                }
            }
            func requestFailure (op: AFHTTPRequestOperation?, error: NSError!) {
                if (op?.responseObject == nil) {
                    return failure(error)
                }
                failure(error)
            }
            
            switch(verb) {
            case "GET":
                manager.GET(BASE_PATH + path, parameters: params, success: requestSuccess, failure: requestFailure)
            case "POST":
                manager.POST(BASE_PATH + path, parameters: params, success: requestSuccess, failure: requestFailure)
            case "DELETE":
                manager.DELETE(BASE_PATH + path, parameters: params, success: requestSuccess, failure: requestFailure)
            default:
                break
            }
    }
    
}