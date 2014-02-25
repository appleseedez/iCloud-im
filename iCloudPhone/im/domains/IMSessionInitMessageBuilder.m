//
//  IMSessionInitMessageBuilder.m
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMSessionInitMessageBuilder.h"
#import "ConstantHeader.h"
#import "IMSeqenceGen.h"
@interface IMSessionInitMessageBuilder()

@end
@implementation IMSessionInitMessageBuilder
// IMMessageBuilder接口

- (NSDictionary*)buildWithParams:(NSDictionary *)params{
    return @{
             kHead:@{
                     kType: [NSNumber numberWithInt:SESSION_INIT_REQ_TYPE],
                     kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                     kSeq:[NSNumber numberWithInteger:[IMSeqenceGen seq]]
                     },
             kBody:params
             
             };
}
@end
