//
//  IMPhoneViewController.h
//  iCloudPhone
//
//  Created by nsc on 14-3-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMPhoneOperatorContext.h"
@class IMManagerImp;
@interface IMPhoneViewController : UIViewController
@property (nonatomic,weak) IMManagerImp *manager;
@property (nonatomic) NSNumber *phoneStatus;
@property (nonatomic) NSNumber *viewStatus;
@end
