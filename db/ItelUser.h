//
//  ItelUser.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface ItelUser : NSManagedObject

@property (nonatomic, retain) NSString * itelNum;
@property (nonatomic, retain) NSString * telNum;
@property (nonatomic, retain) NSString * imageurl;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * accoutType;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * remarkName;
@property (nonatomic, retain) NSNumber * isFriend;
@property (nonatomic, retain) NSNumber * isBlack;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * personalitySignature;
@property (nonatomic, retain) NSString * birthDay;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * qq;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *messages;
@end

@interface ItelUser (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
