//
//  IMTipImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/15/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "IMTipImp.h"
#import "ConstantHeader.h"
static IMTipImp* _instance;
@interface IMTipImp()
@property(nonatomic,copy) NSString* tip;
@property(nonatomic) MSWeakTimer* countDown;
@end

@implementation IMTipImp
+ (void)initialize{
    _instance = [IMTipImp new];
}

+ (instancetype)defaultTip{
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tip = BLANK_STRING;
        [self.countDown invalidate];
    }
    return self;
}

- (void)showTip:(NSString *)tip{
    [self showTip:tip forSeconds:3];
}

- (void)hideTip{
    [self.countDown invalidate];
    self.countDown =nil;
}
- (void)showTip:(NSString *)tip forSeconds:(int)seconds{
    self.tip = tip;
    if (seconds>0) {
        self.countDown = [MSWeakTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(hideTip) userInfo:nil repeats:NO dispatchQueue:dispatch_queue_create("com.itelland.tip_queue", DISPATCH_QUEUE_CONCURRENT)];
    }
}
@end
