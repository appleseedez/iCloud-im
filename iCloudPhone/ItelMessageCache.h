//
//  ItelMessageCache.h
//  iCloudPhone
//
//  Created by nsc on 13-12-30.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItelMessageCache : NSObject
@property (nonatomic,strong) NSMutableArray *messages;
@property (nonatomic,strong) NSString *name;
-(void)addMes:(id)message;
-(id)getMesAtIndex:(NSInteger)index;
-(NSArray*)getUnorderedArray;
-(void)save;
@end
