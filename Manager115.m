//
//  Manager115.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Manager115.h"
#import "ItelAction+_15.h"
@implementation Manager115
static Manager115 *_instance;
+(Manager115*)defaultManager{
    return _instance;
}
+(void)initialize{
    _instance = [Manager115 new];
}
-(void)search115:(NSString*)itel{
    [[ItelAction action] search115:itel];
}
@end
