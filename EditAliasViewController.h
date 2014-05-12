//
//  EditAliasViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItelUser;
@class ContactUserViewModel;
@interface EditAliasViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic,strong) ItelUser *user;
@property (nonatomic,weak) IBOutlet UITextField *txtEditAlias;
@property (nonatomic) ContactUserViewModel *userViewModel;
@end
