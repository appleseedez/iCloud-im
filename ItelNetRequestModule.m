//
//  ItelNetRequestModule.m
//  iCloudPhone
//
//  Created by nsc on 14-4-16.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelNetRequestModule.h"

@implementation ItelNetRequestModule
static ItelNetRequestModule *instance;
+(instancetype)defaultModule{
    return instance;
}
+(void)initialize{
    instance=[ItelNetRequestModule new];
    [instance buildModule];
}
-(void)buildModule{
    self.inRequest=[RACSubject subject];
    self.outFailResponse=[RACSubject subject];
    self.outNetErrorResponse=[RACSubject subject];
    self.outSuccessResponse=[RACSubject subject];
    
    [self.inRequest subscribeNext:^(NSURLRequest *request) {
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (connectionError) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.outNetErrorResponse sendNext:connectionError];
                 });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.outSuccessResponse sendNext:data];
                });
            }
        }];
        
        
        
    }];
    
    
}
@end
