//
//  RacesViewController.swift
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

import UIKit

class RacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sdata: UIImageView!
    @IBOutlet weak var racesTableView: UITableView!
    var _myRaces: [Race] = []
    var _nearRaces: [Race] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Races"

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.sdata.hidden = !Races.sharedRaces().usingSponsoredData;
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.color = navy
        User.storedUser().getMyRaces({ races, err in
            self._myRaces = races
            
            User.storedUser().getNearbyRaces({ races, err in
                self._nearRaces = races
                self.racesTableView.reloadData()
                
                self.sdata.hidden = Races.sharedRaces().usingSponsoredData;
                hud.hide(true)
            })
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self._myRaces.count == 0 && self._nearRaces.count == 0 {
            return UIView()
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("Header") as RaceTableViewHeaderCell
        if section == 0 {
            cell.titleLabel!.text = "My Races"
        } else {
            cell.titleLabel!.text = "Nearby Races"
        }
        return cell.contentView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as RaceTableViewCell
        var race: Race!
        if indexPath.section == 0 {
            race = self._myRaces[indexPath.row]
            cell.joinButton.hidden = true
        } else {
            race = self._nearRaces[indexPath.row]
            cell.joinButton.hidden = false
        }
        cell.titleLabel!.text = race.title
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy h:mm a"
        cell.dateLabel!.text = formatter.stringFromDate(race.startDate)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("mapSegue", sender: self._myRaces[indexPath.row])
        } else {
            self.performSegueWithIdentifier("joinRaceSegue", sender: self._nearRaces[indexPath.row])
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self._myRaces.count
        } else {
            return self._nearRaces.count
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // set dst race from sender
        let race = sender! as Race
        if segue.identifier == "mapSegue" {
            let dst = segue.destinationViewController as MapViewController
            dst.small = false;
            dst.showRace(race)
        } else {
            let dst = segue.destinationViewController as JoinRaceViewController
            dst.race = race
        }
    }

}
