//
//  IMRecentContactItem.h
//  iCloudPhone
//
//  Created by Pharaoh on 12/31/13.
//  Copyright (c) 2013 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMRecentContactItem : NSObject
@property(nonatomic) long sid;
@property(nonatomic,copy) NSString* peerRealName;
@property(nonatomic,copy) NSString* peerNick;
@property(nonatomic,copy) NSString* peerAvatar;
@property(nonatomic,copy) NSString* peerNumber;
@property(nonatomic) NSDate* createDate;
@property(nonatomic,copy) NSString* createDateStr;
@property(nonatomic) NSNumber* duration;
@property(nonatomic,copy) NSString* status;
@end
