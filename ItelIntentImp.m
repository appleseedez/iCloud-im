//
//  ItelIntentImp.m
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelIntentImp.h"
#import "ItelMessageIntent.h"
#import "ItelIntentRefreshData.h"
@implementation ItelIntentImp

+(id<ItelIntent>)newIntent:(intentType)type{
    id <ItelIntent> intent=nil;
    switch (type) {
        case intentTypeMessage:
            intent=[[ItelMessageIntent alloc] init];
            break;
        case intentTypeReloadData:
            intent=[[ItelIntentRefreshData alloc] init];
            break;
            
        default:
            break;
    }
    return intent;
}
-(void)start{
    
}
-(void)dependenceInjection:(id<intentContext>)context{
    self.context=context;
}

@end
