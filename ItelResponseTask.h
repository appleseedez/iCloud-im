//
//  ItelResponseTask.h
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelTaskImp.h"

@interface ItelResponseTask : ItelTaskImp
@property (nonatomic,weak) RACSubject *responseSubject;
@end
