//
//  StrangerViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-27.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "StrangerViewController.h"
#import "ItelAction.h"
#import "NXImageView.h"
#import "NSCAppDelegate.h"
#import "RegNextButton.h"
#import "UIImageView+AFNetworking.h"
#import "Area+toString.h"
@interface StrangerViewController ()
@property (weak, nonatomic) IBOutlet NXImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *lbItel;
@property (weak, nonatomic) IBOutlet UILabel *lbShowName;

@property (weak, nonatomic) IBOutlet RegNextButton *btnAddUser;

@end

@implementation StrangerViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
            return @"基本资料";
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
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 40;
    }
    else return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setFont:[UIFont fontWithName:@"HeiTi SC" size:12]];
    UILabel *prop=[[UILabel alloc]init];
    [cell.contentView addSubview:prop];
    prop.frame=CGRectMake(80, 5, 120, 20);
    [prop setTextColor:[UIColor grayColor]];
    [prop setFont:[UIFont fontWithName:@"HeiTi SC" size:11]];
    if (indexPath.section==1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text=@"姓名";
                prop.text=self.user.nickName;
                break;
            case 1:{
                cell.textLabel.text=@"性别";
                UIImageView *sexImg=[[UIImageView alloc] initWithFrame:CGRectMake(80, 5, 20, 20)];
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
                prop.text = self.user.email;
                break;
                
            default:
                break;
        }
    }
    
    else if (indexPath.section==0){
        cell.textLabel.text=@"签名";
        prop.frame=CGRectMake(80, 5, 200, 30);
        [prop setNumberOfLines:0];
        prop.text=self.user.personalitySignature;
    }
    
    return cell;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshMessage];
	// Do any additional setup after loading the view.
}
-(void)callActionSheet{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加黑名单", nil];
    [actionSheet showInView:self.view];
    
}
- (void)addToBlack:(UIButton *)sender {
    [[ItelAction action] addItelUserBlack:self.user.itelNum];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self addToBlack:nil];
            break;
            
        default:
            break;
    }
}

-(void)refreshMessage{
    if([self.user.remarkName length]>0){
        self.lbShowName.text=[NSString stringWithFormat:@"%@(%@)",self.user.remarkName,self.user.nickName];
    }
    else {
        self.lbShowName.text=self.user.nickName;
    }
    self.lbItel.text = [NSString stringWithFormat:@"itel:%@",self.user.itelNum];
    
}
- (IBAction)addStranger:(UIButton *)sender {
    
    [[ItelAction action] inviteItelUserFriend:self.user.itelNum];
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


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.headImageView setImageWithURL:[NSURL URLWithString:self.user.imageurl] placeholderImage:[UIImage imageNamed:@"头像.png"]];
    
    [self.btnAddUser setUI];
    [self.btnAddUser setTitle:@"添加到通讯录" forState:UIControlStateNormal];
    [self.btnAddUser setTitle:@"添加到通讯录" forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
    [self.headImageView setRect:5.0 cornerRadius:self.headImageView.frame.size.width/6.0 borderColor:[UIColor whiteColor]];
    //[self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddBlack:) name:@"addBlack" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAddFriend:) name:@"inviteItelUser" object:nil];
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:result message:nil delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];

}
-(void)didAddFriend:(NSNotification*)notification{
    BOOL isNormal = [[notification.userInfo objectForKey:@"isNormal"]boolValue];
    NSString *result=nil;
    if (isNormal) {
         result=@"邀请已经发出等待对方确认";
    }
    else {
        result = [notification.userInfo objectForKey:@"reason"];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:result message:nil delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.navigationController setNavigationBarHidden:NO];
}
@end
