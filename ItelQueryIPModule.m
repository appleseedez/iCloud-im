//
//  ItelQueryIPModule.m
//  iCloudPhone
//
//  Created by nsc on 14-4-11.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelQueryIPModule.h"
#import "ItelAction.h"
@implementation ItelQueryIPModule

-(void)buildModule{
    self.inStart=[RACSubject subject];
    self.inStop=[RACSubject subject];
    self.outIP=[RACSubject subject];
    
        [self.inStart subscribeNext:^(NSDictionary *state) {
            [MSWeakTimer
                                     scheduledTimerWithTimeInterval:10
                                     target:self
                                     selector:@selector(keepSession:)
                                     userInfo:@{
                                                PROBE_PORT_KEY :
                                                    [state valueForKey:kForwardPort],
                                                PROBE_SERVER_KEY :
                                                    [state valueForKey:kForwardIP]
                                                }
                                     repeats:YES
                                     dispatchQueue:dispatch_queue_create(
                                                                         "com.itelland.keepIPSession", NULL)];
        }];
       
}
- (void)keepSession:(NSTimer *)timer {
    //#if DEBUG
    //    [[IMTipImp defaultTip] showTip:@"开始发送保持session的数据包"];
    //#endif
    NSDictionary *param = [timer userInfo];
    NSString *probeServerIP = [param valueForKey:PROBE_SERVER_KEY];
    NSInteger port = [[param valueForKey:PROBE_PORT_KEY] integerValue];
    [self.outKeepAlive sendNext:@[probeServerIP,@(port)]];
}


@end
