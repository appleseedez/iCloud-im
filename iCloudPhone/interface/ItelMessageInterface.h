//
//  ItelMessageInterface.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ItelMessageInterface <NSObject>
-(void)addNewMessages:(NSArray*)data;
-(NSArray*)getSystemMessages;

@end