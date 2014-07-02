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
#import "Message.h"
#import <CoreData/CoreData.h>
#import "DBService.h"
#import "MaoAppDelegate.h"
@interface MainTabbarViewController ()
@property (nonatomic)   CustomTabbar *customTabbar;
@property (nonatomic,strong) RACSubject *barSelected;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
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
    [self setupFetchController];
}
-(void)setupFetchController{
    MaoAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    //是否有新的系统消息
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"ItelMessage"];
    request.sortDescriptors=@[];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                             [NSPredicate predicateWithFormat:@"hostItel = %@",[delegate.loginInfo objectForKey:@"itel"]],[NSPredicate predicateWithFormat:@"isNew = %@",@(YES)]                                                                                  ]];
    NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
//    NSArray *systemResult=  [context executeFetchRequest:request error:nil];
//    if ([systemResult count]) {
//        self.customTabbar.imgNewMessage.alpha=1;
//    }else{
//        self.customTabbar.imgNewMessage.alpha=0;
//    }
    self.fetchedResultsController=[[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate=self;
    [self.fetchedResultsController performFetch:nil];
    if ([[self.fetchedResultsController fetchedObjects] count]) {
        self.customTabbar.imgNewMessage.alpha=1;
    }else{
        self.customTabbar.imgNewMessage.alpha=0;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    if ([[controller fetchedObjects] count]) {
        self.customTabbar.imgNewMessage.alpha=1;
    }else{
        self.customTabbar.imgNewMessage.alpha=0;
    }
    NSLog(@"剩余未读%d",[[controller fetchedObjects] count]);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    
    
    
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
      __weak id weekSelf=self;
    for (CustomBarItem *item in self.customTabbar.subviews) {
        if ([item isKindOfClass:[CustomBarItem class]]) {
              item.selectedColor=[UIColor colorWithRed:0.1216 green:0.3961 blue:1.00 alpha:1];
               item.normalColor=[UIColor colorWithRed:0.4745 green:0.4745 blue:0.4745 alpha:1];
           __weak id weekSelf=self;
            [[item rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(CustomBarItem *x) {
              __strong  MainTabbarViewController *strongSelf=weekSelf;
                strongSelf.selectIndex=x.selIndex;
                [strongSelf.barSelected sendNext:x];
                if (strongSelf.dialItem==x) {
                    [strongSelf  presentDialPan];
                }
                            }];
        }
    }
   
    [self.barSelected subscribeNext:^(CustomBarItem *x) {
        __strong  MainTabbarViewController *strongSelf=weekSelf;
        if ([x isKindOfClass:[CustomBarItem class]]) {
            for (CustomBarItem *item in strongSelf.customTabbar.subviews) {
                if ([item isKindOfClass:[CustomBarItem class]]) {
                    if (item!=x) {
                        item.beSelected=@(NO);
                    }else{
                        item.beSelected=@(YES);
                    }
                }
               
            }
        }
       
        [strongSelf setSelectedIndex:[x.selIndex intValue]];
        
    }];
    //监听 显示隐藏tabbar
   
    [RACObserve(self, viewModel.showTabbar) subscribeNext:^(NSNumber *x) {
        __strong MainTabbarViewController *strongSelf=weekSelf;
        BOOL show=[x boolValue];
        NSString *type=@"push";
        NSString *subtype=nil;
        
        if (show) {
            subtype=@"fromTop";
        }else{
            subtype=@"fromBottom";
        }
        if (strongSelf.customTabbar.hidden==show) {
            CATransition *anim=[CATransition animation];
            anim.type=type;
            anim.subtype=subtype;
            anim.duration=0.3;
            [strongSelf.customTabbar setHidden:!show];
            [strongSelf.customTabbar.layer addAnimation:anim forKey:@"4"];
            
        }
        
        
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
- (void)dealloc
{
    NSLog(@"mainTabbarVC被销毁");
}
@end
