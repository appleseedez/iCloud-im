//
//  ItelDBTask.h
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelTaskImp.h"

@interface ItelDBTask : ItelTaskImp
-(ItelDBTask*)buildGetHostTask;
@property (nonatomic) NSString *selectName;
@property (nonatomic) NSString *predicateName;
@property (nonatomic) NSString *predicateValue;
@end
