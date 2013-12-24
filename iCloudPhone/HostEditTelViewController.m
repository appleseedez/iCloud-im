//
//  HostEditTelViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-23.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostEditTelViewController.h"
#import "RegNextButton.h"
@interface HostEditTelViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtTel;
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;

@end

@implementation HostEditTelViewController
-(void)setUI{
    [self.nextButton setUI];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
}


@end
