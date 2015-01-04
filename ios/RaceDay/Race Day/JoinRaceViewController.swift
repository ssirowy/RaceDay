//
//  JoinRaceViewController.swift
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

import UIKit

class JoinRaceViewController: UIViewController {

    @IBOutlet weak var joinLabel: UILabel!
    var race: Race!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.joinLabel.text = "Sign up for the \(self.race.title)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func okButtonPressed(sender: AnyObject) {
        var db = (UIApplication.sharedApplication().delegate as AppDelegate).database
        let doc = db.documentWithID("\(race.raceID)")
        var props = doc.properties
        var users = props["users"]! as [[String: AnyObject]]
        users.append(["email": User.storedUser().email])
        doc.putProperties(props, error: nil)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
