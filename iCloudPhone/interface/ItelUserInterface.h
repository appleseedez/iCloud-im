//
//  ItelUserInterface.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HostItelUser;
@protocol ItelUserInterface <NSObject>
//本机用户
-(HostItelUser*)hostUser;
//设置本机用户
-(void)setHost:(HostItelUser*)host;

-(void)modifyPersonal:(NSDictionary*)data;

@end
