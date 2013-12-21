//
//  ContentViewController.h
//  TV
//
//  Created by nsc on 13-10-24.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
@interface ContentViewController : UIViewController<UIScrollViewDelegate>
@property (nonatomic,weak) id <RoorViewChangingSubPageDelegate> rootDelegate;
@end
