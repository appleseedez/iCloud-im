//
//  Operator.h
//  iCloudPhone
//
//  Created by nsc on 14-3-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMPhoneOperatorContext.h"

@class IMPhoneOperator;
@protocol IMPhoneOperatorInterFace <NSObject>
@optional;
-(void)screenTouched;
+(IMPhoneOperator*)getOperatorWithViewStatus:(IMViewStatus)viewStatus andPhoneStatus:(IMPhoneStatus)phoneStatus;
@end

@interface IMPhoneOperator : NSObject <IMPhoneOperatorInterFace>
@property (nonatomic) UIView *operationView;
@property (nonatomic,weak) id <IMPhoneOperatorContext> context;
@end
