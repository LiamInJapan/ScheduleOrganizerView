//
//  ViewController.m
//  ScheduleOrganizerView
//
//  Created by Conroy, William | Liam | SDTD on 13/03/06.
//  Copyright (c) 2013年 Conroy, William | Liam | SDTD. All rights reserved.
//

#import "ViewController.h"
#import "ScheduleOrganizerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    ScheduleOrganizerView * scheduleOrganizerView = [[ScheduleOrganizerView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:scheduleOrganizerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
