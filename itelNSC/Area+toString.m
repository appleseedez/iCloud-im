//
//  Area+toString.m
//  iCloudPhone
//
//  Created by nsc on 14-1-15.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Area+toString.h"
#import "DBService.h"

@implementation Area (toString)
-(NSString*)toString{
    
 
        
    
        Area *secondArea=[Area idForArea:[NSString stringWithFormat:@"%@",self.parentId]];
    Area *firstArea=[Area idForArea:[NSString stringWithFormat:@"%@",secondArea.parentId]];
    NSString *address=nil;
    if ([Area isDirectCity:[firstArea.areaId intValue]]) {
        address=[NSString stringWithFormat:@"%@-%@",secondArea.name,self.name];
    }
    else{
        address=[NSString stringWithFormat:@"%@-%@-%@",firstArea.name,secondArea.name,self.name];
    }
    return address;
 
    return nil;
}

+(Area*)idForArea:(NSString*)areaId{
    Area *area=nil;
    NSFetchRequest* areaRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    areaRequest.predicate = [NSPredicate predicateWithFormat:@"areaId = %@",areaId];
    NSError *error=nil;
    NSArray* match = [[DBService defaultService].managedObjectContext executeFetchRequest:areaRequest error:&error];
    if ([match count]) {
        area =(Area*)match[0];
    }
    
    return area;
}
+(BOOL)isDirectCity:(NSInteger)code{
    if (code==50) {
        return YES;    //重庆
    }
    if (code==11) {    //北京
        return YES;
    }
    if (code==12) {    //天津
        return YES;
    }
    if (code==31) {    //上海
        return YES;
    }
    
    return NO;
}

@end
