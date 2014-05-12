
//
//  UserViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "UserViewController.h"
#import "EditAliasViewController.h"
#import "ContactUserViewModel.h"


#import "MaoAppDelegate.h"

#import "UIImageView+AFNetworking.h"

@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbShowName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *lbItel;


@end

@implementation UserViewController
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(void)goForewardStep:(id)userInfo{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
            return @"基本资料";
            break;
            
        case 2:
            return @"传统电话";
            break;
            
        default:
            break;
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        case 2:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setFont:[UIFont fontWithName:@"HeiTi SC" size:14]];
    cell.textLabel.backgroundColor=[UIColor clearColor];
    UILabel *prop=[[UILabel alloc]init];
        [cell.contentView addSubview:prop];
                   prop.frame=CGRectMake(60, 10, 220, 20);
    [prop setTextColor:[UIColor grayColor]];
    [prop setFont:[UIFont fontWithName:@"HeiTi SC" size:13]];
    prop.backgroundColor =[UIColor clearColor];
    if (indexPath.section==1) {
        switch (indexPath.row) {
            case 0:
                 cell.textLabel.text=@"姓名";
                 prop.text=self.user.nickName;
                break;
            case 1:{
                cell.textLabel.text=@"性别";
                UIImageView *sexImg=[[UIImageView alloc] initWithFrame:CGRectMake(60, 10, 20, 20)];
                [cell.contentView addSubview:sexImg];
                if ([self.user.sex intValue]) {
                    sexImg.image=[UIImage imageNamed:@"female"];
                }
                else sexImg.image=[UIImage imageNamed:@"male"];
            }
                break;
            case 2:{
                cell.textLabel.text=@"城市";
                
                    prop.text=self.user.address;
                
                
            }
                break;
            case 3:
                cell.textLabel.text=@"邮箱";
                prop.text =self.user.email;
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section==2){
        cell.textLabel.text=@"手机";
        prop.text=self.user.telNum;
    }
    else if (indexPath.section==0){
        cell.textLabel.text=@"签名";
        prop.frame=CGRectMake(60, 0, 260, 45);
        [prop setNumberOfLines:0];
        prop.text=self.user.personalitySignature;
    }
    
    return cell;
}
#pragma mark - 打电话
-(IBAction)vidioCall{
    [self callUserisVidio:YES];
}
-(IBAction)audioCall{
    [self callUserisVidio:NO];
}
- (void)callUserisVidio:(BOOL)isVidio {
   
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [self.userViewModel delUser];
            break;
            
        default:
            break;
    }
}
- (void)delUser:(UIButton *)sender {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"确定要删除？" message:@"删了就找不回来了哦" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [alert show];
    
}
- (void)editAlias:(UIButton *)sender {

    ItelUser *user=self.user;
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Contact" bundle:nil];
   UINavigationController *aliasVC=[storyBoard instantiateViewControllerWithIdentifier:@"editAliasView"];
    EditAliasViewController *editVC=aliasVC.childViewControllers[0];
    editVC.userViewModel=self.userViewModel;
    editVC.user=user;
    [self presentViewController:aliasVC animated:YES completion:^{
        
    }];
}
- (void)addToBlack:(UIButton *)sender {
   //这里添加黑名单
    [self.userViewModel addBlackList];
}

-(void)refreshMessage{
    if([self.user.remarkName length]>0){
        self.lbShowName.text=[NSString stringWithFormat:@"%@(%@)",self.user.remarkName,self.user.nickName];
    }
    else {
        self.lbShowName.text=self.user.nickName;
    }
    self.lbItel.text = [NSString stringWithFormat:@"%@",self.user.itelNum];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userViewModel=[[ContactUserViewModel alloc]init];
    self.userViewModel.user=self.user;
    //监听 修改用户
     [RACObserve(self, userViewModel.user) subscribeNext:^(ItelUser *x) {
         self.user=x;
         [self refreshMessage];
     }];
    
    //监听hud
    [RACObserve(self, userViewModel.busy) subscribeNext:^(NSNumber *x) {
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
    //监听 退出页面
     [RACObserve(self, userViewModel.finish) subscribeNext:^(NSNumber *x) {
         if ([x boolValue]) {
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet) ];
    
    [self.imageView setClipsToBounds:YES];
    [self.imageView.layer setCornerRadius:12];
    [self.imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.imageView.layer setBorderWidth:3.0];
   	
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:self.user.imageurl]placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
    
    
}



-(void)callActionSheet{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除联系人" otherButtonTitles:@"添加黑名单",@"编辑备注", nil];
    [actionSheet showInView: self.view];
    
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    actionSheet.delegate = nil;
    actionSheet = nil;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
            
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        case 0:
            [self delUser:nil];
            break;
        case 2:
            [self editAlias:nil];
            break;
        case 1:
            [self addToBlack:nil];
            break;
            
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 45;
    }
    else return 40;
}


@end
