//
//  MoreViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-12.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "MoreViewController.h"
#import "PersonRegButton.h"
#import "MoreHostViewCell.h"
#import "MoreOtherViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ItelAction.h"
#import "MoreSIgnOutCell.h"
@interface MoreViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PersonRegButton *btnSignOut;


@end

@implementation MoreViewController
- (IBAction)signOut:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController!=self) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTab" object:nil userInfo:@{@"hidden":@"1"}];
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    _btnSignOut.normal=[UIColor redColor];
    self.btnSignOut.high=[UIColor orangeColor];
    [self.btnSignOut setUI];
   [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTab" object:nil userInfo:@{@"hidden":@"0"}];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 1;
            break;
            
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 60;
    }
    else if(indexPath.section!=3){
        return 45;
    }
    else return 60;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *header=[[UIView alloc] init];
// 
//    return nil;
//}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==2||section==3) {
        return 0;
    }
    else return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     NSString *identifier=nil;
    UITableViewCell *cell=nil;
    if (indexPath.section==0) {
         identifier=@"hostCell";
      cell=[tableView dequeueReusableCellWithIdentifier:identifier ];
        [((MoreHostViewCell*)cell).hostImage setRect:0 cornerRadius:8 borderColor:[UIColor clearColor]];
        HostItelUser *host =[[ItelAction action] getHost];
        [((MoreHostViewCell*)cell).hostImage setImageWithURL:[NSURL URLWithString:host.imageUrl] placeholderImage:[UIImage imageNamed:@"头像.png"]];
        ((MoreHostViewCell*)cell).itel.text=host.itelNum;
        ((MoreHostViewCell*)cell).nickName.text=host.nickName;
    }
    else if(indexPath.section!=3){
        
      
        if (indexPath.section==1) {
            switch (indexPath.row) {
                case 0:
                     identifier=@"notificationSetting";
                    break;
                case 1:
                   identifier=@"notificationPush";
                    break;
                case 2:
                   identifier=@"personal";
                    break;
                    
                default:
                    break;
            }
        }
        else if (indexPath.section==2){
            switch (indexPath.row) {
                case 0:
                    identifier=@"itelCeter";
                    break;
                case 1:
                    identifier=@"aboutItel";
                    break;
                    
                default:
                    break;
            }
        }
        
        cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        [((MoreOtherViewCell*)cell).otherLogo setRect:0 cornerRadius:8 borderColor:nil];
        
    }
    else if (indexPath.section==3){
        identifier=@"signOut";
        cell =[tableView dequeueReusableCellWithIdentifier:identifier];
       
        ((MoreSIgnOutCell*)cell).btnSignOut.normal=[UIColor redColor];
        ((MoreSIgnOutCell*)cell).btnSignOut.high=[UIColor orangeColor];
        [((MoreSIgnOutCell*)cell).btnSignOut setUI];
        cell.contentView.backgroundColor=[UIColor clearColor];
    }
    if (indexPath.section!=3) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==3) {
        return NO;
    }
    else return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate=self;
    self.tableView.backgroundColor=[UIColor  clearColor];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
