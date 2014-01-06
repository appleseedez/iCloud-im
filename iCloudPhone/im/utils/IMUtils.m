//
//  IMUtils.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/6/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "IMUtils.h"

@implementation IMUtils
+ (NSString*) secondsToTimeFormat:(NSUInteger) elapsedSeconds{
    NSUInteger h = elapsedSeconds / 3600;
    NSUInteger m = (elapsedSeconds / 60) % 60;
    NSUInteger s = elapsedSeconds % 60;
    
    return [NSString stringWithFormat:@"%u:%02u:%02u", h, m, s];
}
@end
