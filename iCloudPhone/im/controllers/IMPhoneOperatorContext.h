//
//  IMPhoneOperatorContext.h
//  iCloudPhone
//
//  Created by nsc on 14-3-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,IMPhoneStatus ) {
    IMPhoneStatusCalling=1,
    IMPhoneStatusAnswering=2,
    IMPhoneStatusTalking=3,
    IMPhoneStatusEnding=4,
};
typedef NS_ENUM(NSInteger, IMViewStatus) {
    IMViewStatusAudio=1,
    IMViewStatusVideo=2
};
@protocol IMPhoneOperatorContext <NSObject>
@end
