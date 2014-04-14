//
//  ItelEngineModule.h
//  iCloudPhone
//
//  Created by nsc on 14-4-11.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItelEngineModule : NSObject
@property (nonatomic) UIView *pview_local;
@property (nonatomic) RACSubject *inP2P;
@property (nonatomic) RACSubject *isVideo;
@property (nonatomic) RACSubject *keepAlive;
@property (nonatomic) RACSubject *iniNet;
@property (nonatomic) RACSubject *iniMedia;
@property (nonatomic) RACSubject *iniNetFinish;
-(void)buildModule;

- (NSDictionary *)endPointAddressWithProbeServer:(NSString *)probeServerIP
                                            port:(NSInteger)probeServerPort
                                         bakPort:(NSInteger)bakPort;
+(int)getNatType;
@end
