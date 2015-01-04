//
//  DetailsViewController.m
//  Race Day
//
//  Created by Scott Sirowy on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "DetailsViewController.h"
#import "Race.h"

@interface DetailsViewController ()

@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) NSTimeInterval startTime;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeLabel.text = @"";
    self.distanceLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTimer
{
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    _running = YES;
    [self updateTime];
    
    [self updateDistance];
}

- (void)updateTime
{
    if (!self.running) return;
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = currentTime - self.startTime;
    
    int mins = (int)(elapsed / 60.0);
    elapsed -= mins* 60;
    int secs = (int)elapsed;
    elapsed -= secs;
    int fraction = elapsed * 10.0f;
    
    NSString* formattedString = [NSString stringWithFormat:@"%u:%02u.%u", mins, secs, fraction];
    self.timeLabel.text = formattedString;
    
    [self performSelector:@selector(updateTime) withObject:self afterDelay:0.1];
}

- (void)updateDistance
{
    if (!self.running) return;
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f miles. %.1f percent complete", self.race.distanceCovered, self.race.percentageComplete];
    
    [self performSelector:@selector(updateDistance) withObject:self afterDelay:1.0];
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
