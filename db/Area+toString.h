//
//  Area+toString.h
//  iCloudPhone
//
//  Created by nsc on 14-1-15.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Area.h"

@interface Area (toString)
-(NSString*)toString;
+(BOOL)isDirectCity:(NSInteger)code;
+(Area*)idForArea:(NSString*)areaId;
@end
