//
//  ItelBook.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ItelBook.h"
#import "ItelAction.h"
@interface ItelBook()
@property (nonatomic,strong) NSMutableDictionary *users;
@property (nonatomic,strong) NSMutableOrderedSet *keys;
@end
@implementation ItelBook
-(NSMutableDictionary*)users{
    if (_users==nil) {
        _users = [[NSMutableDictionary alloc] init];
    }
    return _users;
}
-(NSMutableOrderedSet*)keys{
    if (_keys==nil) {
        _keys =[[NSMutableOrderedSet alloc] init];
    }
    return _keys;
}

-(void)addUser:(ItelUser*)user forKey:(NSString*)key{
   
       [self.keys addObject:key];
    
        [self.users setObject:user forKey:key];
    
}
-(ItelUser*)userForKey:(NSString*)key  {
   
    ItelUser *user= [self.users objectForKey:key];
    
    return user;
}
//获得所有key
-(NSArray*)getAllKeys{
    NSMutableArray *allkeys=[[NSMutableArray alloc]init];
    for (id k in self.keys) {
        [allkeys addObject:k];
    }
    return allkeys;
}
-(void)removeUserforKey:(NSString*)key{
  
            [self.keys removeObject:key];
            [self.users removeObjectForKey:key];
   
}
- (id)copyWithZone:(NSZone *)zone{
    ItelBook *book=[[ItelBook allocWithZone:zone]init];
    book.users=[self.users mutableCopy];
    book.keys=[self.keys mutableCopy];
    
    return book;
}
-(ItelUser*)userAtIndex:(NSInteger)index{
    if ([self.keys count]>index) {
        NSString *key = [self.keys objectAtIndex:index];
        ItelUser *user=[self.users objectForKey:key];
      return user;
    }
    else return nil;
}
-(ItelBook*)appendingByItelBook:(ItelBook*)itelBook{
    
    for (NSString *key in itelBook.keys) {
        id object = [itelBook userForKey:key];
        [self addUser:object forKey:key];
    }
    return self;
}
-(ItelBook*)searchInKeypath:(NSString*)keypath andSearch:(NSString*)search{
    
    NSMutableArray *searchkeys = [[NSMutableArray alloc]init];
    for (NSString *k in self.keys ) {
        NSString *rKeypath=[NSString stringWithFormat:@"%@.%@",k,keypath];
        [searchkeys addObject:[self.users valueForKeyPath:rKeypath]];
    }
    
   
    
    NSPredicate* searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",search];
    
    NSMutableArray* matched =
    [[searchkeys filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    
    
    ItelBook *result=[[ItelBook alloc] init];
    for (NSString *matchedkey in matched) {
        for (NSString *k in self.keys) {
            ItelUser *user= [self.users objectForKey:k];
            
            NSString* searchKey=[user valueForKeyPath:keypath];
        
                if ([matchedkey isEqualToString:searchKey]) {
                    [result addUser:user forKey:user.itelNum];
                }
       
          
        
        }
    }
    
    
    return result;
}
-(void)reset{
    self.users=nil;
    self.keys=nil;
}
@end
