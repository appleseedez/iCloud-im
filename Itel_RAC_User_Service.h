//
//  Itel_RAC_User_Service.h
//  iCloudPhone
//
//  Created by nsc on 14-4-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Itel_RAC_User_Service : NSObject
@property (nonatomic,strong) RACSubject *netSubject;
@property (nonatomic,strong) RACSubject *DBSubjec;
@property (nonatomic,strong) RACSubject *responseSubject;
@property (nonatomic,strong) RACSubject *serviceSubject;
+(Itel_RAC_User_Service*)defaultService;
@end
