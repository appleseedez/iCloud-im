//
//  ItelQueryIPModule.h
//  iCloudPhone
//
//  Created by nsc on 14-4-11.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItelQueryIPModule : NSObject

@property (nonatomic) RACSubject *inStart;
@property (nonatomic) RACSubject *outIP;
@property (nonatomic) RACSubject *inStop;
@property (nonatomic) RACSubject *outKeepAlive;
-(void)buildModule;
@end
