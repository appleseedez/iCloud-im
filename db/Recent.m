//
//  Recent.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/4/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "Recent.h"
@interface Recent()
@property (nonatomic) NSDate* primitiveCreateDate; //给setCreateDate使用的
@property (nonatomic) NSString* primitiveSectionIdentifier; //存储用于sectionHeader的字段
@end

@implementation Recent

@dynamic createDate;
@dynamic duration;
@dynamic peerAvatar;
@dynamic peerNick;
@dynamic peerNumber;
@dynamic peerRealName;
@dynamic status;
@dynamic sectionIdentifier;
@dynamic primitiveCreateDate;
@dynamic primitiveSectionIdentifier;
@dynamic hostUserNumber;
#pragma mark - Transient properties
- (NSString *)sectionIdentifier{
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString* tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    if (!tmp) {
        NSCalendar* calender = [NSCalendar currentCalendar];
        NSDateComponents* componets = [calender components:(NSYearCalendarUnit |  NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.createDate];
        tmp = [NSString stringWithFormat:@"%d",[componets year]*1000000 + [componets month]*1000+[componets day]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return  tmp;
}

- (void)setCreateDate:(NSDate *)newCreateDate{
    [self willAccessValueForKey:@"createDate"];
    [self setPrimitiveCreateDate:newCreateDate];
    [self didAccessValueForKey:@"createDate"];
    
    [self setPrimitiveSectionIdentifier:nil];
    
}

+ (NSSet *)keyPathsForValuesAffectingCreateDate{
    return [NSSet setWithObject:@"createDate"];
}
@end
