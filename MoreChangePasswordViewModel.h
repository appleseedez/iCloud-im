//
//  MoreChangePasswordViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-21.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@interface MoreChangePasswordViewModel : BaseViewModel
@property (nonatomic) NSNumber *passwordChanged;
-(void)changePassword:(NSString*)newPassword oldPassword:(NSString*)oldPassword;
@end
