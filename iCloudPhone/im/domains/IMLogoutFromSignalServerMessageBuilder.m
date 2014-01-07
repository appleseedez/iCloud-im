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
             HEAD_SECTION_KEY:@{
                     DATA_TYPE_KEY: [NSNumber numberWithInt:CMID_APP_LOGOUT_SSS_REQ_TYPE],
                     DATA_STATUS_KEY:[NSNumber numberWithInt:NORMAL_STATUS],
                     DATA_SEQ_KEY:[NSNumber numberWithInteger:[IMSeqenceGen seq]]
                     },
             BODY_SECTION_KEY:params
             
             };
}
@end
