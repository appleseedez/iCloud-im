//
//  IMDBManagerImp.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/3/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMDBManager.h"
@interface IMDBManagerImp : NSObject <IMDBManager>
@property(nonatomic,copy) NSString*  dbPath; //db文件路径
@property(nonatomic) NSDateFormatter* dbDateFormatter; //db中的日期格式

@end
