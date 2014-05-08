//
//  RoolViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RoolViewController.h"
#import "RootViewModel.h"
#import "MainTabbarViewController.h"
#import "RootTabbarController.h"
#import "DialViewModel.h"
@interface RoolViewController ()
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *sessionView;
@property (nonatomic)  MainTabbarViewController *mainVC;
@property (nonatomic)  RootTabbarController *dialVC;

@end

@implementation RoolViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setSubViewModels];
    
    
    
     //监听 弹出拨号盘
    [RACObserve(self, viewModel.showSessinView) subscribeNext:^(NSNumber *x) {
        CATransition *transition=[CATransition animation];
        transition.type=@"push";
        if ([x boolValue]) {
            
            transition.subtype=@"fromTop";

            
            self.mainView.userInteractionEnabled=NO;
            [self.view bringSubviewToFront:self.sessionView];
            self.sessionView.hidden=NO;
            
            
        }else{
            
            transition.subtype=@"fromBottom";
            self.sessionView.hidden=YES;
            self.mainView.userInteractionEnabled=YES;
             
        }
        [self.sessionView.layer addAnimation:transition forKey:@"3"];
    }];
    
  
}

-(void)setSubViewModels{
    self.viewModel =[[RootViewModel alloc]init];
    UIStoryboard *mainStory=[UIStoryboard storyboardWithName:@"main" bundle:nil];
    self.mainVC=[mainStory  instantiateViewControllerWithIdentifier:@"mainTabbar" ];
    self.mainVC.viewModel=self.viewModel;
    [self.mainView addSubview:self.mainVC.view];
    DialViewModel *dialModel=[[DialViewModel alloc]init];
    UIStoryboard *dialStory=[UIStoryboard storyboardWithName:@"DialView" bundle:nil];
    
    self.dialVC=[dialStory instantiateInitialViewController];
    self.dialVC.viewModel=dialModel;
    dialModel.modelService=self.viewModel;
    self.viewModel.dialViewModel=dialModel;
    [self.sessionView addSubview:self.dialVC.view];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
