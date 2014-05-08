//
//  PassWayViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "PassWayViewController.h"
#import "PassViewModel.h"
#import "PassMesViewController.h"
#import "PassAnswerViewController.h"
#import "PassEmailViewController.h"
@interface PassWayViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *questionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emaiCell;

@end

@implementation PassWayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    [RACObserve(self, passViewModel.securityData) subscribeNext:^(NSDictionary *x) {
        NSDictionary *questions= x;
        NSString *question1=[questions objectForKey:@"question1"];
        NSString *question2=[questions objectForKey:@"question2"];
        NSString *question3=[questions objectForKey:@"question3"];
        if ([self questiongExist:question1]&&[self questiongExist:question2]&&[self questiongExist:question3]) {
            [self showCell:self.questionCell show:YES];
        }
        else {[self showCell:self.questionCell show:NO];}
        NSString *email= [x objectForKey:@"mail"];
        if ([self questiongExist:email]) {
            [self showCell:self.emaiCell show:YES];
        }else{
            [self showCell:self.emaiCell show:NO];
        }
        
    }];
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)showCell:(UITableViewCell*)cell show:(BOOL)show {
    
    cell.hidden=!show;
}
-(BOOL)questiongExist:(NSString*)question{
    if ([question isKindOfClass:[NSString class]]) {
        if (question.length>0) {
            return  YES;
        }
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc=segue.destinationViewController;
    if ([vc isKindOfClass:[PassMesViewController class]]) {
        ((PassMesViewController*)vc).passViewModel=self.passViewModel;
        [self.passViewModel sendMessage];
     
    }else if([vc isKindOfClass:[PassAnswerViewController class]]){
        ((PassAnswerViewController*)vc).passViewModel=self.passViewModel;
    }else if([vc isKindOfClass:[PassEmailViewController class]]){
        ((PassEmailViewController*)vc).passViewModel=self.passViewModel;
        [self.passViewModel sendEmail];
    }
}
@end
