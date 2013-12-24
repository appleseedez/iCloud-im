//
//  HostCell.h
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HostItelUser.h"
@protocol HostCell <NSObject>
@optional;
-(void) showSettingView:(UIViewController*)viewController;
@required;
-(void) setPro:(HostItelUser*)host;
@end
