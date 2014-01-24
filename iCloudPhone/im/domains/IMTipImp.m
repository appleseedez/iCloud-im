//
//  IMTipImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/15/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "IMTipImp.h"
#import "ConstantHeader.h"
#import "ALAlertBanner.h"
#import "NSCAppDelegate.h"
static IMTipImp* _instance;
@interface IMTipImp()
@property(nonatomic,copy) NSString* tip;
@property(nonatomic) ALAlertBannerStyle style;
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
- (void) errorTip:(NSString *)tip{
    self.style = ALAlertBannerStyleFailure;
    [self showTip:tip];
}
- (void) warningTip:(NSString *)tip{
    self.style = ALAlertBannerStyleWarning;
    [self showTip:tip];
}
- (void)successTip:(NSString *)tip{
    self.style = ALAlertBannerStyleSuccess;
    [self showTip:tip];
}
- (void)showTip:(NSString *)tip forSeconds:(int)seconds{
    self.tip = tip;
    NSCAppDelegate *appDelegate = (NSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    ALAlertBannerStyle randomStyle = self.style;// (ALAlertBannerStyle)(arc4random_uniform(4));
    ALAlertBannerPosition position = ALAlertBannerPositionTop;
    ALAlertBanner* banner = [ALAlertBanner alertBannerForView:appDelegate.window style:randomStyle position:position title:self.tip subtitle:@"" ];
    banner.secondsToShow = 1.5;
    banner.showAnimationDuration = .25;
    banner.hideAnimationDuration = .2;

    dispatch_async(dispatch_get_main_queue(), ^{
        [ALAlertBanner hideAllAlertBanners];
        NSLog(@"我在弹:%@",self.tip);
        [banner show];
    });
    
    self.style = ALAlertBannerStyleSuccess;
    
}
@end
