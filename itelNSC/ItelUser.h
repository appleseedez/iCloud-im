//
//  ItelUser.h
//  itelNSC
//
//  Created by nsc on 14-5-10.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ItelUser : NSManagedObject

@property (nonatomic, retain) NSString * accoutType;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * birthDay;
@property (nonatomic, retain) NSString * emain;
@property (nonatomic, retain) NSString * imageurl;
@property (nonatomic, retain) NSNumber * isBlack;
@property (nonatomic, retain) NSNumber * isFriend;
@property (nonatomic, retain) NSString * itelNum;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * personalitySignature;
@property (nonatomic, retain) NSString * qq;
@property (nonatomic, retain) NSString * remarkName;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * telNum;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSString * email;

@end