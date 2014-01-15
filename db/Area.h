//
//  Area.h
//  iCloudPhone
//
//  Created by nsc on 14-1-14.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Area : NSManagedObject

@property (nonatomic, retain) NSNumber * areaId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * capital;
@property (nonatomic, retain) NSString * sequence;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * parentId;

@end
