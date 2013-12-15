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
@interface MoreViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PersonRegButton *btnSignOut;

@end

@implementation MoreViewController
- (IBAction)signOut:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _btnSignOut.normal=[UIColor redColor];
    self.btnSignOut.high=[UIColor orangeColor];
    [self.btnSignOut setUI];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
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
            
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 60;
    }
    else return 45;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *header=[[UIView alloc] init];
// 
//    return nil;
//}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     NSString *identifier=nil;
    UITableViewCell *cell=nil;
    if (indexPath.section==0) {
         identifier=@"hostCell";
      cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        [((MoreHostViewCell*)cell).hostImage setRect:0 cornerRadius:8 borderColor:[UIColor clearColor]];
        
    }
    else{
        identifier=@"otherCell";
      cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        [((MoreOtherViewCell*)cell).otherLogo setRect:0 cornerRadius:8 borderColor:nil];
        UILabel *text=((MoreOtherViewCell*)cell).moreTitle;
        if (indexPath.section==1) {
            switch (indexPath.row) {
                case 0:
                     text.text=@"通知设置";
                    break;
                case 1:
                    text.text=@"来电设置";
                    break;
                case 2:
                    text.text=@"隐身设置";
                    break;
                    
                default:
                    break;
            }
        }
        else if (indexPath.section==2){
            switch (indexPath.row) {
                case 0:
                    text.text=@"iTel应用中心";
                    break;
                case 1:
                    text.text=@"关于";
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    return cell;
}
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellAccessoryDisclosureIndicator;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor=[UIColor  clearColor];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
