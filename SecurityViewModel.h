//
//  SecurityViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-22.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@interface SecurityViewModel : BaseViewModel
@property (nonatomic) NSDictionary *questionData;
@property (nonatomic) NSNumber *answerPassed;
@property (nonatomic) NSNumber *modifySuccess;
-(void)getSecurity;
-(void)checkAnswer:(NSString*)question answer:(NSString*)answer;
-(void)modifyProtection:(NSDictionary*)parameters;

@end
