//
//  IMAuthMessageBuilder.m
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMAuthMessageBuilder.h"
#import "ConstantHeader.h"
#import "IMSeqenceGen.h"
@implementation IMAuthMessageBuilder

- (NSDictionary *)buildWithParams:(NSDictionary *)params{
    return @{
             kHead:@{
                     kType: [NSNumber numberWithInt:CMID_APP_LOGIN_SSS_REQ_TYPE],
                     kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                     kSeq:[NSNumber numberWithInteger:[IMSeqenceGen seq]]
                     },
             kBody:params
             
             };
}
@end
