//
//  NSManagedObject+RAC.h
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (RAC)
-(void)setWithDic:(NSDictionary*)dic andContext:(NSManagedObjectContext*)context;
@end
