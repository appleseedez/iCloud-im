//
//  PassViewController.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PassViewModel;
@interface PassViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic,strong) PassViewModel *passViewModel;
@end
