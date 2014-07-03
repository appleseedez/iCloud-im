//
//  Recent.h
//  itelNSC
//
//  Created by nsc on 14-7-3.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItelUser;

@interface Recent : NSManagedObject

@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * callOrAnswer;
@property (nonatomic, retain) NSNumber * peerItel;
@property (nonatomic, retain) NSString * targetItel;
@property (nonatomic, retain) ItelUser *targetUser;

@end
