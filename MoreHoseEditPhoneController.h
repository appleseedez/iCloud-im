//
//  MoreHoseEditPhoneController.h
//  itelNSC
//
//  Created by nsc on 14-5-20.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MorePhoneViewModel;
@interface MoreHoseEditPhoneController : UIViewController <UITextFieldDelegate>
@property  (nonatomic) MorePhoneViewModel *phoneViewModel;

@end
