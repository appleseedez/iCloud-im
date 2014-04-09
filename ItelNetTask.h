//
//  ItelNetTask.h
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelTaskImp.h"

typedef NS_ENUM (NSInteger, ItelNetTaskInterface){
    ItelNetTaskInterfaceUpdateUser,//修改hostUser属性
    
};

typedef NS_ENUM (NSInteger, ItelNetTaskRequestType){
    ItelNetTaskRequestTypeGet,
    ItelNetTaskRequestTypeJsonPost
    
};
@interface ItelNetTask : ItelTaskImp
-(ItelNetTask*)buildWithInterFace:(ItelNetTaskInterface)interface userInfo:(id)userInfo;
@property (nonatomic) ItelNetTaskRequestType requestType;
@property (nonatomic) NSString *url;
@property (nonatomic) NSDictionary *parameters;
@property (nonatomic) RACSubject *failuerSubject;
@property (nonatomic) NSString *codeKeyPath;
@end
