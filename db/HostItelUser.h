//
//  HostItelUser.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItelUser, Message;

@interface HostItelUser : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSNumber * countType;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * itelNum;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * personalitySignature;
@property (nonatomic, retain) NSString * port;
@property (nonatomic, retain) NSString * qq;
@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * spring_security_remember_me_cookie;
@property (nonatomic, retain) NSString * stunServer;
@property (nonatomic, retain) NSString * telNum;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSSet *friendBook;
@property (nonatomic, retain) NSSet *blackBook;
@property (nonatomic, retain) NSSet *systemMessages;
@end

@interface HostItelUser (CoreDataGeneratedAccessors)

- (void)addFriendBookObject:(ItelUser *)value;
- (void)removeFriendBookObject:(ItelUser *)value;
- (void)addFriendBook:(NSSet *)values;
- (void)removeFriendBook:(NSSet *)values;

- (void)addBlackBookObject:(ItelUser *)value;
- (void)removeBlackBookObject:(ItelUser *)value;
- (void)addBlackBook:(NSSet *)values;
- (void)removeBlackBook:(NSSet *)values;

- (void)addSystemMessagesObject:(Message *)value;
- (void)removeSystemMessagesObject:(Message *)value;
- (void)addSystemMessages:(NSSet *)values;
- (void)removeSystemMessages:(NSSet *)values;

@end
