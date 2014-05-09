//
//  MainTabbarViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MainTabbarViewController.h"
#import "CustomTabbar.h"
#import "CustomBarItem.h"
#import "RootViewModel.h"
#import "DialViewModel.h"
@interface MainTabbarViewController ()
@property (nonatomic)   CustomTabbar *customTabbar;
@property (nonatomic,strong) RACSubject *barSelected;
@end

@implementation MainTabbarViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSubControllers];
    self.barSelected =[RACSubject subject];
    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"CustomTabbar" owner:self options:nil];
    
    self.customTabbar = [nib objectAtIndex:0];
    self.customTabbar.center=CGPointMake(160, self.view.bounds.size.height-self.customTabbar.bounds.size.height/2.0);
    [self.customTabbar bringSubviewToFront:self.mainItem];
    [self.view addSubview:self.customTabbar];
    [self setBarItems];
   
    [self.view addSubview:self.customTabbar];
    [self.tabBar removeFromSuperview];
    [self.barSelected sendNext:self.mainItem];
}
-(void)setSubControllers{
    NSString *storyID=nil;
    for (UIViewController *vc in self.viewControllers) {
        NSUInteger i=[self.viewControllers indexOfObject:vc];
        switch (i) {
            case 0:
                storyID=@"Recent";
                break;
            case 1:
                storyID=@"Contact";
                break;
            case 3:
                storyID=@"Message";
                break;
            case 4:
                storyID=@"More";
                break;
                
            default:
                break;
        }
        if (storyID) {
            UIStoryboard *story=[UIStoryboard storyboardWithName:storyID bundle:nil];
            if ([vc isKindOfClass:[UINavigationController class]]) {
                ((UINavigationController*)vc).viewControllers=@[[story instantiateInitialViewController]];
            }
        }
    }
}
-(void)setBarItems{
    self.dialItem.imgSelected=[UIImage imageNamed:@"tab_1a"];
    self.dialItem.imgNormal=[UIImage imageNamed:@"tab_1"];
    self.dialItem.selIndex=@(0);
    
    self.contactItem.imgSelected=[UIImage imageNamed:@"tab_2a"];
    self.contactItem.imgNormal=[UIImage imageNamed:@"tab_2"];
    self.contactItem.selIndex=@(1);
    
    self.mainItem.imgSelected=[UIImage imageNamed:@"tab_3a"];
    self.mainItem.imgNormal=[UIImage imageNamed:@"tab_3"];
    self.mainItem.selIndex=@(2);
    
    self.messageItem.imgSelected=[UIImage imageNamed:@"tab_4a"];
    self.messageItem.imgNormal=[UIImage imageNamed:@"tab_4"];
    self.messageItem.selIndex=@(3);
    
    self.moreItem.imgSelected=[UIImage imageNamed:@"tab_5a"];
    self.moreItem.imgNormal=[UIImage imageNamed:@"tab_5"];
    self.moreItem.selIndex=@(4);
    
    for (CustomBarItem *item in self.customTabbar.subviews) {
        if ([item isKindOfClass:[CustomBarItem class]]) {
              item.selectedColor=[UIColor colorWithRed:0.1216 green:0.3961 blue:1.00 alpha:1];
               item.normalColor=[UIColor colorWithRed:0.4745 green:0.4745 blue:0.4745 alpha:1];
            
            [[item rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(CustomBarItem *x) {
                self.selectIndex=x.selIndex;
                [self.barSelected sendNext:x];
                if (self.dialItem==x) {
                    [self  presentDialPan];
                }
                            }];
        }
    }
    [self.barSelected subscribeNext:^(CustomBarItem *x) {
        
        for (CustomBarItem *item in self.customTabbar.subviews) {
            if (item!=x) {
                item.beSelected=@(NO);
            }else{
                item.beSelected=@(YES);
            }
        }
        [self setSelectedIndex:[x.selIndex intValue]];
        
    }];
    
}
-(void)chooseSelectedView:(NSInteger)index{
    CustomBarItem *item=nil;
    if (index==[self.dialItem.selIndex integerValue]) {
        item=self.dialItem;
    }else if(index==[self.moreItem.selIndex integerValue]) {
        item=self.moreItem;
    }else if(index==[self.contactItem.selIndex integerValue]) {
        item=self.contactItem;
    }else if(index==[self.mainItem.selIndex integerValue]) {
        item=self.mainItem;
    }else if(index==[self.messageItem.selIndex integerValue]) {
        item=self.messageItem;
    }
    [self.barSelected sendNext:item];
}
-(void)presentDialPan{
    self.viewModel.dialViewModel.showingView=@(ViewTypeDialing);
    self.viewModel.showSessinView=@(YES);
}
@end
