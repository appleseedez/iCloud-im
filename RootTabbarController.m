//
//  RootTabbarController.m
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RootTabbarController.h"
#import "VideoAnsweringViewController.h"
#import "VideoCallingViewController.h"
#import "VideoSessionViewController.h"
#import "AudioAnsweringViewController.h"
#import "AudioCallingViewController.h"
#import "AudioSessionViewController.h"
#import "DialingViewController.h"
#import "DialViewModel.h"

@interface RootTabbarController ()
@property  (nonatomic,strong)  VideoAnsweringViewController *vAnsweringVC;
@property  (nonatomic,strong) VideoCallingViewController *vCallingVC;
@property  (nonatomic,strong) VideoSessionViewController *vSessionVC;
@property  (nonatomic,strong) AudioAnsweringViewController *aAnsweringVC;
@property  (nonatomic,strong) AudioCallingViewController *aCallingVC;
@property  (nonatomic,strong) AudioSessionViewController *aSessionVC;

@property  (nonatomic,strong) DialingViewController *dialingVC;
@end

@implementation RootTabbarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        //self.viewModel=[DialViewModel new];
    __weak id weakSelf=self;
    [RACObserve(self, viewModel.showingView) subscribeNext:^(id x) {
        __strong RootTabbarController *strongSelf=weakSelf;
        if (x !=nil) {
         
            NSInteger type=(NSInteger)[(NSNumber*)x integerValue];
            UIViewController *vc;
            switch (type) {
                case ViewTypeVAnsering:
                    vc=strongSelf.vAnsweringVC;
                    break;
                case ViewTypeVCalling:
                    vc=strongSelf.vCallingVC;
                    break;
                case ViewTypeVsession:
                    vc=strongSelf.vSessionVC;
                    break;
                case ViewTypeAAnsering:
                    vc=strongSelf.aAnsweringVC;
                    break;
                case ViewTypeACalling:
                    vc=strongSelf.aCallingVC;
                    break;
                case ViewTypeAsession:
                    vc=strongSelf.aSessionVC;
                    break;
                case ViewTypeDialing:
                    vc=strongSelf.dialingVC;
                    break;
                
                    
                default:
                    break;
            }
            [strongSelf setViewController:vc];
        }
    }];
    
   
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0) {
        
    }else{
        self.view.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
  
    
    
    
    
   
}

-(void)setViewController:(UIViewController*)controller{
    [UIView animateWithDuration:0.3 animations:^{
         [self.view addSubview:controller.view];
         // [controller viewWillAppear:NO];
    }];
   
}



-(DialingViewController*)dialingVC{
    if (_dialingVC==nil) {
        _dialingVC=[self.storyboard instantiateViewControllerWithIdentifier:@"dialingVC"];
        _dialingVC.viewModel=self.viewModel;
    }
    
    return _dialingVC;
}

-(VideoAnsweringViewController*)vAnsweringVC{
    if (_vAnsweringVC==nil) {
        _vAnsweringVC=[self.storyboard instantiateViewControllerWithIdentifier:@"vAnsweringVC"];
        _vAnsweringVC.viewModel=self.viewModel;
    }
    return _vAnsweringVC;
}
-(VideoSessionViewController*)vSessionVC{
    if (_vSessionVC==nil) {
        _vSessionVC=[self.storyboard instantiateViewControllerWithIdentifier:@"vSessionVC"];
        _vSessionVC.viewModel=self.viewModel;
    }
    
    return _vSessionVC;
}

-(VideoCallingViewController*)vCallingVC{
    if (_vCallingVC==nil) {
        _vCallingVC=[self.storyboard instantiateViewControllerWithIdentifier:@"vCallingVC"];
        _vCallingVC.viewModel=self.viewModel;
    }
    
    return _vCallingVC;
}
-(AudioAnsweringViewController*)aAnsweringVC{
    if (_aAnsweringVC==nil) {
        _aAnsweringVC=[self.storyboard instantiateViewControllerWithIdentifier:@"aAnsweringVC"];
        _aAnsweringVC.viewModel=self.viewModel;
    }
    
    return _aAnsweringVC;
}
-(AudioCallingViewController*)aCallingVC{
    if (_aCallingVC==nil) {
        _aCallingVC=[self.storyboard instantiateViewControllerWithIdentifier:@"aCallingVC"];
        _aCallingVC.viewModel=self.viewModel;
    }
    
    return _aCallingVC;
}
-(AudioSessionViewController*)aSessionVC{
    if (_aSessionVC==nil) {
        _aSessionVC=[self.storyboard instantiateViewControllerWithIdentifier:@"aSessionVC"];
        _aSessionVC.viewModel=self.viewModel;
    }
    
    return _aSessionVC;
}

-(void)dealloc{
    NSLog(@"%@被销毁",self);
}

@end
