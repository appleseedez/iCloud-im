//
//  Operator.m
//  iCloudPhone
//
//  Created by nsc on 14-3-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "IMPhoneOperator.h"
#import "IMPhoneOperatorAudioCall.h"
@implementation IMPhoneOperator
+(IMPhoneOperator*)getOperatorWithViewStatus:(IMViewStatus)viewStatus andPhoneStatus:(IMPhoneStatus)phoneStatus{
    
      IMPhoneOperator *phoneOperator =nil;
    
    //音频拨打
    if (viewStatus==IMViewStatusAudio&&phoneStatus==IMPhoneStatusCalling) {
        phoneOperator= [IMPhoneOperatorAudioCall new];
    }
    return phoneOperator;
}
@end
