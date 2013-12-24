//
//  SecuretyQuestiongViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassSecuretyQuestiongViewController.h"
#import "RegNextButton.h"
@interface PassSecuretyQuestiongViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;

@end

@implementation PassSecuretyQuestiongViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nextButton setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
