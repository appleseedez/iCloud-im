//
//  Message.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/8/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItelUser;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) ItelUser *sender;

@end
