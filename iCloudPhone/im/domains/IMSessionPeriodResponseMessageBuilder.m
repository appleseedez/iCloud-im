//
//  IMSessionPeriodResponseMessageBuilder.m
//  im
//
//  Created by Pharaoh on 13-11-22.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMSessionPeriodResponseMessageBuilder.h"
#import "ConstantHeader.h"
#import "IMSeqenceGen.h"
@implementation IMSessionPeriodResponseMessageBuilder
- (NSDictionary *)buildWithParams:(NSDictionary *)params{
    NSError* error;
    NSDictionary* result = @{
                             kHead:@{
                                     kType: [NSNumber numberWithInt:SESSION_PERIOD_REQ_TYPE],
                                     kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                                     kSeq:[NSNumber numberWithInteger:[IMSeqenceGen seq]]
                                     },
                             kBody:@{
                                     kDestAccount:[params valueForKey:kSrcAccount],
                                     kData:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:&error]  encoding:NSUTF8StringEncoding],
                                     kDataType:[NSNumber numberWithInt:EDT_SIGNEL]
                                     
                                     }
                             
                             };
    if (error) {
        [NSException exceptionWithName:@"400:Data Parse Error" reason:@"json数据构造失败" userInfo:nil];
        return @{};
    }
    return result;
}
@end
