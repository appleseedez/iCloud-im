//
//  ItelNetInterfaceImp+_15.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelNetInterfaceImp+_15.h"

@interface ItelNetInterfaceImp ()
-(void)requestWithName:(NSString*)name parameters:(NSDictionary*)parameters Method:(int)method responseSelector:(SEL)selector userInfo:(id)userInfo  notifyName:(NSString*)notifyName;
@end

@implementation ItelNetInterfaceImp (_15)

-(void)search115:(NSDictionary *)parameters{
    [self requestWithName:@"/user/searchItel.json" parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"search115Response:") userInfo:@"data" notifyName:@"115search"];
}
@end
