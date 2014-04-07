//
//  Itel_User_Intent.h
//  iCloudPhone
//
//  Created by nsc on 14-4-7.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Itel_User_Intent : NSObject
@property (nonatomic , strong) NSDictionary *netRequestParameters;
@property (nonatomic,strong)  NSDictionary *DBParameters;
@property (nonatomic,strong)  NSDictionary *viewParameters;
@property (nonatomic) NSString *notifyName;
@end
