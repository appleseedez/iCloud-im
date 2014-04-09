//
//  ItelNetTask.m
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelNetTask.h"
#import "ItelAction.h"
@implementation ItelNetTask
-(ItelNetTask*)buildWithInterFace:(ItelNetTaskInterface)interface userInfo:(id)userInfo{
    HostItelUser *hostUser=[[ItelAction action]getHost];
    switch (interface) {
        case  ItelNetTaskInterfaceUpdateUser:
        {
    self.requestType=ItelNetTaskRequestTypeJsonPost;
    self.parameters=@{@"userId":hostUser.userId ,@"itel":hostUser.itelNum,@"token":hostUser.token,@"key":[userInfo objectForKey:@"key"],@"value":[userInfo objectForKey:@"value"]};
    self.url=[NSString stringWithFormat:@"%@/user/updateUser.json",SIGNAL_SERVER];
            break;
        }
            
            
            
        default:
            break;
    }
    
    
    
    return self;
}
@end
