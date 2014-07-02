//
//  Message.h
//  itelNSC
//
//  Created by nsc on 14-6-30.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content; //消息内容
@property (nonatomic, retain) NSDate * date;     //发送日期 (longlong)
@property (nonatomic, retain) NSString * hostItel; //发送的()
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSString * targetItel;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;

@end
