//
//  RaceViewController.swift
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

import UIKit

class RaceViewController: UIViewController, UIPageViewControllerDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var _race: Race!
    var pageViewController: UIPageViewController!
    var mapPage: MapViewController!
    var detailsPage: DetailsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapPage = storyboard!.instantiateViewControllerWithIdentifier("mapViewController") as MapViewController
        self.mapPage.showRace(self._race)
        self.detailsPage = storyboard!.instantiateViewControllerWithIdentifier("detailsViewController") as DetailsViewController
        
        self.detailsPage.race = self._race
        
        self.pageViewController.setViewControllers([self.mapPage], direction: UIPageViewControllerNavigationDirection.Reverse, animated: false, completion: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSegue" {
            self.pageViewController = segue.destinationViewController as UIPageViewController
            self.pageViewController.delegate = self
        }
    }

    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            self.pageViewController.setViewControllers([self.detailsPage], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        } else {
            
            self.pageViewController.setViewControllers([self.mapPage], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
        }
    }
}
