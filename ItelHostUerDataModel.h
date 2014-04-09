//
//  ItelHostUerDataModel.h
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HostItelUser;
@interface ItelHostUerDataModel : NSObject
@property (nonatomic) RACSubject *inModifySubject;
@property (nonatomic) RACSubject *inSetSubject;
@property (nonatomic) RACSubject *outSubject;
@property (nonatomic) HostItelUser *hostUser;
@end
