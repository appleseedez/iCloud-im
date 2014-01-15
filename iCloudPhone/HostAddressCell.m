//
//  HostAddressCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostAddressCell.h"
#import "Area.h" 
#import <CoreData/CoreData.h>

#import "IMCoreDataManager.h"
@implementation HostAddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setPro:(HostItelUser *)host{
    Area *thirdArea=[self idForArea:host.address];
    Area *secondArea=[self idForArea:[NSString stringWithFormat:@"%@",thirdArea.parentId]];
    Area *firstArea=[self idForArea:[NSString stringWithFormat:@"%@",secondArea.parentId]];
    NSString *address=nil;
    if ([self isDirectCity:[firstArea.areaId intValue]]) {
       address=[NSString stringWithFormat:@"%@-%@",secondArea.name,thirdArea.name];
    }
    else{
       address=[NSString stringWithFormat:@"%@-%@-%@",firstArea.name,secondArea.name,thirdArea.name];
    }
    if (thirdArea!=nil) {
        self.addressLable.text=address;
        
    }
    
}
-(Area*)idForArea:(NSString*)areaId{
    Area *area=nil;
    NSFetchRequest* areaRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    areaRequest.predicate = [NSPredicate predicateWithFormat:@"areaId = %@",areaId];
    NSError *error=nil;
    NSArray* match = [[IMCoreDataManager defaulManager].managedObjectContext executeFetchRequest:areaRequest error:&error];
    if ([match count]) {
        area =(Area*)match[0];
    }
    
    return area;
}
-(BOOL)isDirectCity:(NSInteger)code{
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
