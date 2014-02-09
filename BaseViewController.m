//
//  BaseViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController


-(void) mentionMessage:(id)message{
    if ([message isKindOfClass:[NSDictionary class]]) {
        NSDictionary *mes=(NSDictionary*)message;
        NSString *title=[mes objectForKey:@"title"];
        NSString *body=[mes objectForKey:@"body"];
        NSString *otherSelection=[mes objectForKey:@"otherSelection"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:@"取消" otherButtonTitles:otherSelection,nil];
        [alert show];
    }
}
-(void) goForewardStep:(id)userInfo{
    
}
-(void) reloadData:(id)userInfo{
   
}

-(void) intentEnd:(id <ItelIntent> )intent{
    if (intent.nextIntent) {
        self.currIntent=intent.nextIntent;
        [intent.nextIntent dependenceInjection:self];
        [intent.nextIntent start];
    }else{
        self.currIntent=nil;
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        self.currIntent=nil;
    }else{
        [self intentEnd:self.currIntent];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)handlNotification:(NSNotification*)notification{
    id <ItelIntent> intent=nil;
    intent = [notification.userInfo valueForKey:@"intent"];
    self.currIntent=intent;
    [intent dependenceInjection:self];
    [intent start];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for (NSString *notification in self.notifications) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlNotification:) name:notification object:nil];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
