//
//  GraphViewController.m
//  RaceDay
//
//  Created by Scott Sirowy on 1/4/15.
//  Copyright (c) 2015 Questionable Intent. All rights reserved.
//

#import "GraphViewController.h"
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

@interface GraphViewController ()

@property (nonatomic, strong) BEMSimpleLineGraphView* graphView;

@end

@implementation GraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _graphView = [[BEMSimpleLineGraphView alloc] initWithFrame:self.view.bounds];
    _graphView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.graphView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
