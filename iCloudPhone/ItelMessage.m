//
//  ItelMessage.m
//  iCloudPhone
//
//  Created by nsc on 13-12-26.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "ItelMessage.h"

@implementation ItelMessage
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder  encodeObject:self.title forKey:@"title"];
    [aCoder  encodeObject:self.body forKey:@"body"];
    [aCoder  encodeObject:self.date forKey:@"date"];
    [aCoder  encodeObject:self.user forKey:@"user"];
    NSString *isRead=nil;
    if (self.isRead) {
        
        isRead=@"1";
    }
    else isRead=@"0";
    [aCoder  encodeObject:isRead forKey:@"isRead"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self.title= [aDecoder decodeObjectForKey:@"title"];
    self.body= [aDecoder decodeObjectForKey:@"body"];
    self.date= [aDecoder decodeObjectForKey:@"date"];
    self.isRead=[[aDecoder decodeObjectForKey:@"isRead"] boolValue];
    self.user= [aDecoder decodeObjectForKey:@"user"];
    return self;
}
+(ItelMessage*)messageWithDic:(NSDictionary*)data{
    ItelMessage *mes=[[ItelMessage alloc]init];
    mes.date=[data objectForKey:@"date"];
    mes.body=[data objectForKey:@"msg"];
    mes.title=@"请求加你好友";
    mes.user=[data objectForKey:@"contact"];
    return mes;
}
@end
