
//
//  UserViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "UserViewController.h"
#import "EditAliasViewController.h"
#import "ItelAction.h"
#import "NXImageView.h"
#import "IMManager.h"
#import "NSCAppDelegate.h"
#import "NSCAppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "Area+toString.h"
#import "IMTipImp.h"
@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbShowName;
@property (weak, nonatomic) IBOutlet NXImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *lbItel;


@end

@implementation UserViewController
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
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
    UILabel *prop=[[UILabel alloc]init];
        [cell.contentView addSubview:prop];
                   prop.frame=CGRectMake(60, 10, 220, 20);
    [prop setTextColor:[UIColor grayColor]];
    [prop setFont:[UIFont fontWithName:@"HeiTi SC" size:13]];
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
                if (self.user.sex) {
                    sexImg.image=[UIImage imageNamed:@"female"];
                }
                else sexImg.image=[UIImage imageNamed:@"male"];
            }
                break;
            case 2:{
                cell.textLabel.text=@"城市";
                Area *area=[Area idForArea:self.user.address];
                if (area) {
                    prop.text=area.toString;
                }
                
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
    NSCAppDelegate *appDelegate = (NSCAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.manager setIsVideoCall:isVidio];
   
    
    [appDelegate.manager dial:self.user.itelNum];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [[ItelAction action] delFriendFromItelBook:self.user.itelNum];
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
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
   UINavigationController *aliasVC=[storyBoard instantiateViewControllerWithIdentifier:@"editAliasView"];
    ((EditAliasViewController*)aliasVC.topViewController).user=user;
    
    [self presentViewController:aliasVC animated:YES completion:^{
        
    }];
}
- (void)addToBlack:(UIButton *)sender {
    [[ItelAction action] addItelUserBlack:self.user.itelNum];
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
    //self.navigationController.navigationBarHidden=YES;
    [self refreshMessage];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet) ];

    
   	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self registerNotifcations];
    [self.imageView setImageWithURL:[NSURL URLWithString:self.user.imageurl]];
    
    [self.imageView setRect:2.0 cornerRadius:self.imageView.frame.size.width/6.0 borderColor:[UIColor whiteColor]];
    
}


- (void) registerNotifcations{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAliasChanged:) name:@"resetAlias" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAddBlack:) name:@"addBlack" object:nil];
    //删除成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delNotification:) name:@"delItelUser" object:nil];
    
}
-(void)callActionSheet{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除联系人" otherButtonTitles:@"添加黑名单",@"编辑备注", nil];
    [actionSheet showInView: self.view];
    
}
- (void) delNotification:(NSNotification*) notify{
    BOOL isNormal = [[notify.userInfo objectForKey:@"isNormal"] boolValue];
    if (isNormal) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[IMTipImp defaultTip] errorTip:@"当前网络异常,删除失败"];
    }
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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
  
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)didAddBlack:(NSNotification*)notification{
    BOOL isNormal = [[notification.userInfo objectForKey:@"isNormal"]boolValue];
    NSString *result=nil;
    if (isNormal) {
        result=@"添加黑名单成功";
    }
    else {
        result = @"添加黑名单失败";
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:result message:@"该用户已在您的黑名单列表中" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
    
}
-(void)userAliasChanged:(NSNotification*)notification{
    ItelUser *user=(ItelUser*)notification.object ;
    self.user=user ;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshMessage];
    });
    
}
@end
