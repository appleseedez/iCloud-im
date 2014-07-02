//
//  ReacabilityManager.h
//  itelNSC
//
//  Created by nsc on 14-6-25.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ENUM(NSInteger, netStatus){
    netStatusWifi,
    netStatus3G,
    netStatusNonet
};
@interface ReacabilityManager : NSObject
+(instancetype)defarutManager;
@property (nonatomic) NSNumber *currNetStatus;
@end
