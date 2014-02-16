//
//  IMLogoutFromSignalServerMessageBuilder.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "IMLogoutFromSignalServerMessageBuilder.h"
#import "ConstantHeader.h"
#import "IMSeqenceGen.h"
@implementation IMLogoutFromSignalServerMessageBuilder
- (NSDictionary *)buildWithParams:(NSDictionary *)params{
    return @{
             kHead:@{
                     kType: [NSNumber numberWithInt:CMID_APP_LOGOUT_SSS_REQ_TYPE],
                     kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                     kSeq:[NSNumber numberWithInteger:[IMSeqenceGen seq]]
                     },
             kBody:params
             
             };
}
@end
