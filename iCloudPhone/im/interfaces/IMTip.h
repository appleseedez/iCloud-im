//
//  IMTip.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/15/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMTip <NSObject>
- (void) showTip:(NSString*) tip forSeconds:(int) seconds; //显示x秒后消失
- (void) showTip:(NSString*) tip;
- (void) hideTip;
@end
