//
//  ItelMessageManager.m
//  iCloudPhone
//
//  Created by nsc on 13-12-30.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "ItelMessageManager.h"
#import "ItelAction.h"
@implementation ItelMessageManager

static ItelMessageManager *manager;
- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

+ (void)initialize{
    manager = [[ItelMessageManager alloc] init];
}
+(ItelMessageManager*)defaultManager{

    return manager;
}
- (void) setup{
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearching) name:@"rootViewAppear" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSearching) name:@"rootViewDisappear" object:nil];
}

-(ItelMessageCache*)systemMessageCache{
    if (_systemMessageCache==nil) {
        _systemMessageCache=[[ItelMessageCache alloc]init];
        _systemMessageCache.name=@"addFriendsMesList";
    }
    return _systemMessageCache;
}
-(void)tearDown{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)startSearching{
    [self sendSearching];
   self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendSearching) userInfo:nil repeats:YES];
}
-(void)sendSearching{
    [[ItelAction action] searchForNewMessage];
}
-(void)stopSearching{
    [self.timer invalidate];
    self.timer=nil;
}
-(void)addNewMessages:(NSArray*)data{
    if ([data isKindOfClass:[NSArray class]]) {
        for(NSDictionary *mesDic in data ){
            ItelMessage *message=[ItelMessage messageWithDic:mesDic];
            [self.systemMessageCache addMes:message];
        }
    }
    [self.systemMessageCache save];
}
-(NSArray*)getSystemMessages{
    return [self.systemMessageCache getUnorderedArray];
}
@end
