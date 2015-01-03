//
//  MapViewController.m
//  Race Day
//
//  Created by Dick Fickling on 1/3/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "MapViewController.h"
#import <ArcGIS/ArcGIS.h>

@interface MapViewController ()

@property (nonatomic, strong) AGSMapView* mapView;
@property (nonatomic, strong) AGSCredential* credential;

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
    NSURL* url = [NSURL URLWithString:@"http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [mapView addMapLayer:tiledLayer withName:@"Basemap"];
}


/*
- (void)viewDidAppear:(BOOL)animated
{
    _credential = [[AGSCredential alloc] initWithUser:@"scottsirowy" password:@"Crowded2000"];
    
    NSURL* pointsURL = [NSURL URLWithString:@"http://services1.arcgis.com/W4Noi4OZras42xbd/arcgis/rest
    
    [self.mapView addMapLayer:points];
    
    NSURL* linesURL = [NSURL URLWithString:@"http://services1.arcgis.com/W4Noi4OZras42xbd/arcgis/rest/services/Lines/FeatureServer/0"];
    AGSFeatureLayer* lines = [[AGSFeatureLayer alloc] initWithURL:linesURL mode:AGSFeatureLayerModeSnapshot credential:self.credential];
    
    [self.mapView addMapLayer:lines];
    
    AGSEnvelope* redlands = [AGSEnvelope envelopeWithXmin:-13046781.151300
                                                     ymin:4032015.796770
                                                     xmax:-13042560.702336
                                                     ymax:4039522.568662
                                         spatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [self.mapView zoomToEnvelope:redlands animated:YES];
    
    _queryTask = [[AGSQueryTask alloc] initWithURL:linesURL credential:self.credential];
    AGSQuery* query = [AGSQuery query];
    query.whereClause = @"1=1";
    query.outFields = @[@"*"];
    query.returnGeometry = YES;
    query.outSpatialReference =  [AGSSpatialReference webMercatorSpatialReference];
    
    self.queryTask.delegate = self;
    [self.queryTask executeWithQuery:query];
}
 */


@end
