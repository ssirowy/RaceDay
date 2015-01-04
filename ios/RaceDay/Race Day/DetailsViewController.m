//
//  DetailsViewController.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "DetailsViewController.h"
#import "Race.h"
#import "GraphViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import <RaceDay-Swift.h>

@interface DetailsViewController ()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, retain) UIPageViewController* pageViewController;
@property (nonatomic, retain) MapViewController* mapPage;
@property (nonatomic, retain) GraphViewController* graphPage;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.distanceLabel.text = @"";
    
    self.mapPage = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];

    [self.mapPage showRace:self.race];
    self.mapPage.small = true;
    
    self.graphPage = [self.storyboard instantiateViewControllerWithIdentifier:@"graphViewController"];
    self.graphPage.race = self.race;
    
    [self.pageViewController setViewControllers:@[self.mapPage] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:NULL];
    
    
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController == self.mapPage) {
        return NULL;
    } else {
        return self.mapPage;
    }
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    if (viewController == self.graphPage) {
        return NULL;
    } else {
        return self.graphPage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedSegue"]) {
        self.pageViewController = segue.destinationViewController;
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
    }
}

- (void)startTimer
{
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    _running = YES;
    [self updateTime];
    
    [self updateDistance];
    
    [self updateCouch];
    
    [self updatePlace];
}

- (void)updateTime
{
    if (!self.running) return;
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = currentTime - self.startTime;
    
    int mins = (int)(elapsed / 60.0);
    elapsed -= mins* 60;
    int secs = (int)elapsed;
    
    NSString* formattedString = [NSString stringWithFormat:@"%02u:%02u", mins, secs];
    self.timeLabel.text = formattedString;
    
    [self performSelector:@selector(updateTime) withObject:self afterDelay:0.1];
}

- (void)updateDistance
{
    if (!self.running) return;
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", self.race.distanceCovered];
    
    [self performSelector:@selector(updateDistance) withObject:self afterDelay:1.0];
}

- (void)updatePlace
{
    if (!self.running) return;
    
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    CBLDatabase* db = delegate.database;
    
    CBLDocument* doc = [db documentWithID: self.race.raceID.stringValue];
    NSMutableDictionary* p = CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)doc.properties, kCFPropertyListMutableContainers));
    NSMutableArray* users = p[@"users"];
    NSNumber* userDistance = [[NSNumber alloc] init];
    NSMutableArray* places = [[NSMutableArray alloc] init];
    for (int i = 0; i < users.count; i++) {
        NSDictionary* user = users[i];
        NSArray* evts = user[@"data"];
        if (evts.count == 0) {
            continue;
        } else {
            NSDictionary* evt = evts[0];
            NSNumber* distance = evt[@"distance"];
            if ([[[User storedUser] email] isEqualToString:user[@"email"]]) {
                userDistance = distance;
            }
            int j = 0;
            bool inserted = false;
            while (j < places.count) {
                NSNumber* place = places[j];
                if (place > distance) {
                    [places insertObject:distance atIndex:j];
                    inserted = true;
                    break;
                }
            }
            if (!inserted) {
                [places addObject:distance];
            }
        }
    }
    
    NSUInteger place = [places indexOfObject:userDistance];
    
    if (place == 1) {
        self.overallLabel.text = @"1st";
        self.ageGroupLabel.text = @"1st";
    } else if (place == 2) {
        self.overallLabel.text = @"2nd";
        self.ageGroupLabel.text = @"2nd";
    } else if (place == 3) {
        self.overallLabel.text = @"3rd";
        self.ageGroupLabel.text = @"3rd";
    }
    
    [self performSelector:@selector(updatePlace) withObject:self afterDelay:1.0];
}

- (void)updateCouch
{
    if (!self.running) return;
    
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    CBLDatabase* db = delegate.database;
    
    CBLDocument* doc = [db documentWithID: self.race.raceID.stringValue];
    NSMutableDictionary* p = CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)doc.properties, kCFPropertyListMutableContainers));
    NSMutableArray* users = p[@"users"];
    
    for (int i = 0; i < users.count; i++) {
        NSMutableDictionary* user = users[i];
        if ([[[User storedUser] email] isEqualToString:user[@"email"]]) {
            NSMutableArray* evts = user[@"data"];
            
            NSDictionary* event = @{
                                    @"status": @"update",
                                    @"distance": [[NSNumber alloc] initWithDouble:self.race.distanceCovered],
                                    @"timestamp": [[NSNumber alloc] initWithDouble:[[[NSDate alloc] init] timeIntervalSince1970]],
                                    @"location": @{
                                            @"latitude": [[NSNumber alloc] initWithDouble:self.race.currentLocation.y],
                                            @"longitude": [[NSNumber alloc] initWithDouble:self.race.currentLocation.x]
                                            }
                                    };
            
            [evts removeAllObjects];
            
            [evts addObject:event];
            NSError* error;
            if (![doc putProperties: p error: &error]) {
            }
        }
    }
    
    
    [self performSelector:@selector(updateCouch) withObject:self afterDelay:2];
}

- (void)stopTimer
{
    self.running = NO;
}

- (void)setRace:(Race *)race
{
    if (_race) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kRaceStartedNotification object:_race];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kRaceEndedNotification object:_race];
    }
    
    if (race) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startTimer)
                                                     name:kRaceStartedNotification
                                                   object:race];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopTimer)
                                                     name:kRaceEndedNotification
                                                   object:race];
    }
    
    _race = race;
}

@end
