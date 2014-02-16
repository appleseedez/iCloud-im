//
//  IMSessionRefuseMessageBuilder.m
//  im
//
//  Created by Pharaoh on 13-11-24.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMSessionRefuseMessageBuilder.h"
#import "ConstantHeader.h"
#import "IMSeqenceGen.h"
@implementation IMSessionRefuseMessageBuilder
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
#if SIGNAL_MESSAGE
    NSLog(@"结束信令:%@",result);
#endif
    return result;
}
@end
