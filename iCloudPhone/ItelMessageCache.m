//
//  ItelMessageCache.m
//  iCloudPhone
//
//  Created by nsc on 13-12-30.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "ItelMessageCache.h"
#import "ItelAction.h"
@implementation ItelMessageCache


-(NSMutableArray*)messages{
    HostItelUser *host = [[ItelAction action] getHost];
     NSString *path=[NSString stringWithFormat:@"%@/Documents/HOST%@%@",NSHomeDirectory(),host.itelNum,self.name];
    if (_messages==nil) {
        _messages=[NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (_messages==nil) {
            _messages=[[NSMutableArray alloc]init];
        }
    }
    return _messages;
}
-(void)addMes:(id)message{
    [self.messages addObject:message];
    while ([self.messages count]>100) {
        [self.messages removeObjectAtIndex:0];
    }
    [self save];
}

-(id)getMesAtIndex:(NSInteger)index{
    if (index+1<=[self.messages count]) {
         return [self.messages objectAtIndex:index];
    }
    else return nil;
}
-(NSArray*)getUnorderedArray{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    for(int i=[self.messages count]; i>0; i--){
        [array addObject:[self.messages objectAtIndex:i-1]];
    }
    return array;
}
-(void)save{
    HostItelUser *host = [[ItelAction action] getHost];
    NSString *path=[NSString stringWithFormat:@"%@/Documents/HOST%@%@",NSHomeDirectory(),host.itelNum,self.name];
    [NSKeyedArchiver archiveRootObject:self.messages toFile:path];
}
@end
