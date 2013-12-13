//
//  SearchNavController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-12.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SearchNavController.h"
#import "ConstantHeader.h"
#import "IMAnsweringViewController.h"
#import "IMCallingViewController.h"
@interface SearchNavController ()
@property(nonatomic,weak) id<IMManager> manager;
@end

@implementation SearchNavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


@end
