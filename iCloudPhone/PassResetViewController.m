//
//  PassResetViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassResetViewController.h"
#import "RegNextButton.h"
@interface PassResetViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;

@end

@implementation PassResetViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.nextButton setUI];
}



@end
