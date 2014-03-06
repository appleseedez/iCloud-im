//
//  IMIphoneViewController.h
//  iCloudPhone
//
//  Created by nsc on 14-3-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMManagerImp.h"
#import "IMPhoneOperatorContext.h"
@interface IMIphoneViewController : UIViewController <IMPhoneOperatorContext>
@property (nonatomic,weak) IMManagerImp *manager;
@property (nonatomic) NSNumber *phoneStatus;
@property (nonatomic) NSNumber *viewStatus;
@end
