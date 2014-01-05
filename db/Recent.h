//
//  Recent.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/4/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Recent : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * peerAvatar;
@property (nonatomic, retain) NSString * peerNick;
@property (nonatomic, retain) NSString * peerNumber;
@property (nonatomic, retain) NSString * peerRealName;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * sectionIdentifier;
@property (nonatomic, retain) NSString * hostUserNumber;
@end
