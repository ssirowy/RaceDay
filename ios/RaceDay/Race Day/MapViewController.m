//
//  MapViewController.m
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "MapViewController.h"
#import "Races.h"
#import "Race.h"
#import <ArcGIS/ArcGIS.h>

#define kLightBasemapURL @"http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer"
#define kDarkBasemapURL @"http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"

@interface MapViewController ()

@property (nonatomic, strong) AGSMapView* mapView;
@property (nonatomic, strong) AGSCredential* credential;

@property (nonatomic, strong) Race* currentRace;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AGSMapView* mapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mapView = mapView;
    
    [self.view addSubview:mapView];
    
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:kLightBasemapURL];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [mapView addMapLayer:tiledLayer withName:@"Basemap"];
}


- (void)viewDidAppear:(BOOL)animated
{
    Races* races = [Races sharedRaces];
    AGSFeatureLayer* lines = [[AGSFeatureLayer alloc] initWithURL:races.url
                                                             mode:AGSFeatureLayerModeSnapshot
                                                       credential:races.credential];
    
    [self.mapView addMapLayer:lines];
    
    __weak MapViewController* weakSelf = self;
    [races findRacesWithCompletion:^(NSArray* races, NSError* e) {
    
        Race* r = [races lastObject];
        [weakSelf showRace:r];
    }];
    
}

- (void)showRace:(Race*)race
{
    _currentRace = race;
    
    AGSMutableEnvelope* me = [race.graphic.geometry.envelope mutableCopy];
    [me expandByFactor:1.4];
    [self.mapView zoomToEnvelope:me animated:YES];
}

@end
