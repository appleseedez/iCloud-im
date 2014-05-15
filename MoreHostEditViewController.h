//
//  MoreHostEditViewController.h
//  itelNSC
//
//  Created by nsc on 14-5-15.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MoreViewModel;
@interface MoreHostEditViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic) NSInteger limitInput;
@property (nonatomic) NSString *placeHolder;
@property (nonatomic) NSString *titleText;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) NSString *key;
@property (nonatomic,weak) MoreViewModel *moreViewModel;
@property (nonatomic) NSString *oldValue;
@end
