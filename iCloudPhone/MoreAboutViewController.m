//
//  MoreAboutViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-3-4.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "MoreAboutViewController.h"
#import "ItelAction.h"
@interface MoreAboutViewController ()

@end

@implementation MoreAboutViewController

-(IBAction)checkNewVersion:(id)sender{
    
    [[ItelAction action] checkNewVersion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNewVersion:) name:@"checkNewVersion" object:nil];
}
-(void)isNewVersion:(NSNotification*)notification{
    NSLog(@"%@", [notification.userInfo objectForKey:@"reason"]);
}
@end
