//
//  RacesViewController.swift
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

import UIKit

class RacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nearbyRacesTableView: UITableView!
    @IBOutlet weak var myRacesTableView: UITableView!
    var _myRaces: [Race] = []
    var _nearRaces: [Race] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        User.storedUser().getMyRaces({ races, err in
            self._myRaces = races
            self.myRacesTableView.reloadData()
            
            User.storedUser().getNearbyRaces({ races, err in
                self._nearRaces = races
                self.nearbyRacesTableView.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        var race: Race!
        if tableView == self.myRacesTableView {
            race = self._myRaces[indexPath.row]
        } else {
            race = self._nearRaces[indexPath.row]
        }
        cell.textLabel!.text = race.title
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy h:mm a"
        cell.detailTextLabel!.text = formatter.stringFromDate(race.startDate)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.myRacesTableView {
            self.performSegueWithIdentifier("myRaceSegue", sender: self._myRaces[indexPath.row])
        } else {
            self.performSegueWithIdentifier("joinRaceSegue", sender: self._nearRaces[indexPath.row])
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.myRacesTableView {
            return self._myRaces.count
        } else {
            return self._nearRaces.count
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // set dst race from sender
        let race = sender! as Race
        if segue.identifier == "myRaceSegue" {
            let dst = segue.destinationViewController as RaceViewController
            dst._race = race
        } else {
            let dst = segue.destinationViewController as JoinRaceViewController
            dst.race = race
        }
    }

}
