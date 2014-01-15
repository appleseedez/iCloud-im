//
//  PassWayViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassWayViewController.h"
#import "PassManager.h"
@interface PassWayViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *questionSecurityCell;

@end

@implementation PassWayViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *questions= [PassManager defaultManager].questions;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    NSString *question1=[questions objectForKey:@"question1"];
    NSString *question2=[questions objectForKey:@"question2"];
    NSString *question3=[questions objectForKey:@"question3"];
    if ([self questiongExist:question1]&&[self questiongExist:question2]&&[self questiongExist:question3]) {
        [self showSecurity:YES];
    }
    else [self showSecurity:NO];
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)showSecurity:(BOOL)show{
  
    self.questionSecurityCell.hidden=!show;
}
-(BOOL)questiongExist:(NSString*)question{
    if ([question isKindOfClass:[NSString class]]) {
        if (question.length>0) {
            return  YES;
        }
    }
    return NO;
}
@end
