//
//  HostMesViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-12-23.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "RegMesCheckViewController.h"

@interface HostMesViewController : RegMesCheckViewController{
    NSString * _newTelNum;
}
-(NSString*)newTelNum;
-(void)setNewTelNum:(NSString*)newTelNum;
@end
