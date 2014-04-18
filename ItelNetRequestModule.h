//
//  ItelNetRequestModule.h
//  iCloudPhone
//
//  Created by nsc on 14-4-16.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItelNetRequestModule : NSObject
@property  (nonatomic,strong) RACSubject *inRequest;
@property  (nonatomic,strong) RACSubject *outFailResponse;
@property  (nonatomic,strong) RACSubject *outNetErrorResponse;
@property  (nonatomic,strong) RACSubject *outSuccessResponse;
-(void)buildModule;
+(instancetype)defaultModule;
@end
