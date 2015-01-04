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
#import "DetailsViewController.h"
#import "UIColor+Additions.h"

#import "M2X.h"

#define kLightBasemapURL @"http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer"
#define kDarkBasemapURL @"http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"

@interface MapViewController () <AGSMapViewLayerDelegate>

@property (nonatomic, strong) RaceMapView* mapView;

@property (nonatomic, strong) Race* currentRace;

@property (nonatomic, strong) AGSGraphicsLayer* geofenceLayer;
@property (nonatomic, assign) BOOL showingGeofences;

@property (nonatomic, strong) AGSGraphicsLayer* startStopLayer;

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
    
    [self.mapView reset];
    
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:kLightBasemapURL];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Basemap"];
    
    _geofenceLayer = [AGSGraphicsLayer graphicsLayer];
    
    Races* races = [Races sharedRaces];
    AGSFeatureLayer* lines = [[AGSFeatureLayer alloc] initWithURL:races.url
                                                             mode:AGSFeatureLayerModeSnapshot
                                                       credential:races.credential];
    
    [self.mapView addMapLayer:lines];
    [self.mapView addMapLayer:self.geofenceLayer];
    
    
    if (self.small) {
        self.mapView.userInteractionEnabled = false;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailsViewController* dvc = segue.destinationViewController;
    dvc.race = sender;
}
     
- (void)startRace
{
    [self.currentRace startRaceSimulatedSpeed:RaceSimulatedSpeedSlow];
    [self performSegueWithIdentifier:@"showDetailsSegue" sender:self.currentRace];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.mapView removeMapLayer:self.geofenceLayer];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                                           target:self
                                                                                           action:@selector(startRace)];
    
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
        [me expandByFactor:self.small ? 1.8 : 1.4];
        [self.mapView zoomToEnvelope:me animated:YES];
        
        [self addStartStopLayer];
    }
    else {
        self.needToLoadRace = YES;
    }
    
    self.title = race.title;
}

- (void)addStartStopLayer
{
    [self.geofenceLayer removeAllGraphics];
    
    AGSSimpleLineSymbol* startLine = [AGSSimpleLineSymbol simpleLineSymbol];
    startLine.color = [UIColor darkGreenColor];
    
    AGSSimpleLineSymbol* finishLine = [AGSSimpleLineSymbol simpleLineSymbol];
    finishLine.color = [UIColor darkRedColor];
    
    // Add geofences to map
    AGSSimpleFillSymbol* startSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    startSymbol.color = [[UIColor darkGreenColor] colorWithAlphaComponent:0.5];
    startSymbol.outline = startLine;
    
    AGSSimpleFillSymbol* finishSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    finishSymbol.color = [[UIColor darkRedColor] colorWithAlphaComponent:0.5];
    finishSymbol.outline = finishLine;
    
    AGSGraphic* fence1 = [AGSGraphic graphicWithGeometry:self.currentRace.startRaceGeofence
                                                  symbol:startSymbol
                                              attributes:nil];
    
    AGSGraphic* fence2 = [AGSGraphic graphicWithGeometry:self.currentRace.endRaceGeofence
                                                  symbol:finishSymbol
                                              attributes:nil];
    
    [self.geofenceLayer removeAllGraphics];
    [self.geofenceLayer addGraphics:@[fence1, fence2]];
    
    [self.mapView addMapLayer:self.geofenceLayer];
}

@end
