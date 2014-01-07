//
//  ItelMessageInterfaceImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "ItelMessageInterfaceImp.h"
#import "ItelAction.h"
#import "Message+CRUD.h"
#import "IMCoreDataManager.h"
@interface ItelMessageInterfaceImp()
@property(nonatomic) NSTimer* timer;
@end

@implementation ItelMessageInterfaceImp
- (void) setup{
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearching) name:@"rootViewAppear" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSearching) name:@"rootViewDisappear" object:nil];
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
            [Message messageWithDic:mesDic inContext:[IMCoreDataManager defaulManager].managedObjectContext];
        }
        [[IMCoreDataManager defaulManager] saveContext];
    }
}
-(NSArray*)getSystemMessages{

    return [Message allMessagesInContext:[IMCoreDataManager defaulManager].managedObjectContext];
}

@end
