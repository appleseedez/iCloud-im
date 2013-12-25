//
//  SecurityViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-25.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecurityViewController.h"
#import "ItelAction.h"
@interface SecurityViewController ()

@end

@implementation SecurityViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        switch (indexPath.row) {
            case 0:
                [self checkSecurity];
                break;
            case 1:
                [self pushToChangePasswordView];
                break;
            default:
                break;
        }
    }
}
-(void)pushToChangePasswordView{
    
}
-(void)checkSecurity{
    [[ItelAction action] checkOutProtection];
}

@end
