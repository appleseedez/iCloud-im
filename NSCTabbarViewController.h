//
//  NSCTabbarViewController.h
//  iCloudPhone
//
//  Created by nsc on 14-3-24.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSCTabbarViewController : UIViewController
-(void)setSelectedIndex:(NSInteger)index;
@property (nonatomic,strong) NSArray *viewControllers;
@end
