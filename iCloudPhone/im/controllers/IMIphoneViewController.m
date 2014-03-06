//
//  IMIphoneViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-3-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "IMIphoneViewController.h"
#import "IMPhoneOperator.h"
#import "NSCAppDelegate.h"
@interface IMIphoneViewController ()
@property (nonatomic) IMPhoneOperator *phoneOperator;
@property (nonatomic,weak)UIViewController *videoVC;
@property (nonatomic,weak)UIViewController *audioVC;


@end

@implementation IMIphoneViewController

@synthesize viewStatus=_viewStatus;
@synthesize phoneStatus=_phoneStatus;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager=((NSCAppDelegate*)[UIApplication sharedApplication].delegate).manager;
    self.videoVC=[self.childViewControllers objectAtIndex:1];
    self.audioVC=[self.childViewControllers objectAtIndex:0];
	// Do any additional setup after loading the view.
}

-(void)setCurrSubView:(IMViewStatus)viewStatus{
    if (viewStatus==IMViewStatusAudio) {
        self.videoVC.view.alpha=0;
        self.audioVC.view.alpha=1;
    }else if(viewStatus==IMViewStatusVideo){
        self.videoVC.view.alpha=1;
        self.audioVC.view.alpha=0;
    }
    
}
-(void)setStatus{
    if ([self.phoneStatus integerValue]==IMPhoneStatusCalling) {
        if (self.manager.isVideoCall==YES){
            self.viewStatus=@(IMViewStatusVideo);
        }else{
            self.viewStatus=@(IMViewStatusAudio);
        }
    }
}
static  void *viewStatusContext=(void*)&viewStatusContext;
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context==viewStatusContext) {
        IMViewStatus value=(IMViewStatus)[[change objectForKey:@"new"]integerValue];
        [self setCurrSubView:value];
    }
}
@end
