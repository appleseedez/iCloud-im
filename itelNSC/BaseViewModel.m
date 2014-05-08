//
//  BaseViewModel.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-5.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@implementation BaseViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.httpService=[HTTPService defaultService];
        self.requestBuilder=[HTTPRequestBuilder defaultBuilder];
    }
    return self;
}
-(void)netRequestError:(NSError*)error{
    [[[UIAlertView alloc]initWithTitle:@"网络故障" message:@"请检查您的网络连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
}
-(void)netRequestFail:(NSDictionary*)data{
    [[[UIAlertView alloc]initWithTitle:[data objectForKey:@"msg"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
}
-(void)serverError{
    [[[UIAlertView alloc]initWithTitle:@"服务器异常" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
}
@end
