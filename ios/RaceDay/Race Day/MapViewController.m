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
@property (nonatomic, strong) UIButton* toggleFencesButton;

@property (nonatomic, strong) Race* currentRace;

@property (nonatomic, strong) AGSGraphicsLayer* geofenceLayer;
@property (nonatomic, assign) BOOL showingGeofences;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AGSMapView* mapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mapView = mapView;
    
    [self.view addSubview:mapView];
    
    _toggleFencesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_toggleFencesButton setTitle:@"Start" forState:UIControlStateNormal];
    _toggleFencesButton.frame = CGRectMake(0, 0, 100, 50);
    _toggleFencesButton.backgroundColor = [UIColor whiteColor];
    [_toggleFencesButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_toggleFencesButton];
    
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:kLightBasemapURL];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [mapView addMapLayer:tiledLayer withName:@"Basemap"];
    
    _geofenceLayer = [AGSGraphicsLayer graphicsLayer];
}

- (void)start
{
    NSLog(@"Start");
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
    
    [self.mapView removeMapLayer:self.geofenceLayer];
}

- (void)showRace:(Race*)race
{
    _currentRace = race;
    
    AGSMutableEnvelope* me = [race.graphic.geometry.envelope mutableCopy];
    [me expandByFactor:1.4];
    [self.mapView zoomToEnvelope:me animated:YES];
    
    if (race) {
        _showingGeofences = NO;
        [self toggleGeofences];
    }
}

- (void)toggleGeofences
{
    [self.mapView removeMapLayer:self.geofenceLayer];
    
    // If not showing, add layer for visualization purposes
    if (!self.showingGeofences) {
        
        AGSSimpleLineSymbol* sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
        sls1.color = [UIColor blueColor];
        
        AGSSimpleLineSymbol* sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
        sls2.color = [UIColor blueColor];
        
        
        // Add geofences to map
        AGSSimpleFillSymbol* sfs1 = [AGSSimpleFillSymbol simpleFillSymbol];
        sfs1.color = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        sfs1.outline = sls1;
        
        AGSSimpleFillSymbol* sfs2 = [AGSSimpleFillSymbol simpleFillSymbol];
        sfs2.color = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        sfs2.outline = sls2;
        
        AGSGraphic* fence1 = [AGSGraphic graphicWithGeometry:self.currentRace.startRaceGeofence
                                                      symbol:sfs1
                                                  attributes:nil];
        
        AGSGraphic* fence2 = [AGSGraphic graphicWithGeometry:self.currentRace.endRaceGeofence
                                                      symbol:sfs2
                                                  attributes:nil];
        
        [self.geofenceLayer removeAllGraphics];
        [self.geofenceLayer addGraphics:@[fence1, fence2]];
        
        [self.mapView addMapLayer:self.geofenceLayer];
    }
    
    _showingGeofences = !_showingGeofences;
}

@end
