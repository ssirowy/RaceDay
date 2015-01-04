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
#import "RaceMapView.h"
#import <ArcGIS/ArcGIS.h>

#define kLightBasemapURL @"http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer"
#define kDarkBasemapURL @"http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"

@interface MapViewController () <AGSMapViewLayerDelegate>

@property (nonatomic, strong) RaceMapView* mapView;

@property (nonatomic, strong) Race* currentRace;

@property (nonatomic, strong) AGSGraphicsLayer* geofenceLayer;
@property (nonatomic, assign) BOOL showingGeofences;

@property (nonatomic, assign) BOOL needToLoadRace;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mapView = [RaceMapView sharedMapView];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.frame = self.view.bounds;
    self.mapView.layerDelegate = self;
    
    [self.view addSubview:self.mapView];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"Start race" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 120, 40);
    [button addTarget:self action:@selector(startRace) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:kLightBasemapURL];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Basemap"];
    
    _geofenceLayer = [AGSGraphicsLayer graphicsLayer];
}

- (void)startRace
{
    [self.currentRace startRaceSimulatedSpeed:RaceSimulatedSpeedFast];
}

- (void)viewDidAppear:(BOOL)animated
{
    Races* races = [Races sharedRaces];
    AGSFeatureLayer* lines = [[AGSFeatureLayer alloc] initWithURL:races.url
                                                             mode:AGSFeatureLayerModeSnapshot
                                                       credential:races.credential];
    
    [self.mapView addMapLayer:lines];
    
    [self.mapView removeMapLayer:self.geofenceLayer];
}

- (void)mapViewDidLoad:(AGSMapView *)mapView
{
    if (self.needToLoadRace) {
        [self showRace:self.currentRace];
    }
    
    self.needToLoadRace = NO;
}

- (void)showRace:(Race*)race
{
    _currentRace = race;
    if (self.mapView.loaded) {
        
        AGSMutableEnvelope* me = [race.graphic.geometry.envelope mutableCopy];
        [me expandByFactor:1.4];
        [self.mapView zoomToEnvelope:me animated:YES];
        
        if (race) {
            _showingGeofences = NO;
            [self toggleGeofences];
        }
    }
    else {
        self.needToLoadRace = YES;
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
