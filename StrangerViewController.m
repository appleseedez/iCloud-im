//
//  StrangerViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-27.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "StrangerViewController.h"
#import "SearchViewModel.h"
#import "ItelUser+CRUD.h"
#import "MaoAppDelegate.h"

#import "UIImageView+AFNetworking.h"

@interface StrangerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *lbItel;
@property (weak, nonatomic) IBOutlet UILabel *lbShowName;

@property (weak, nonatomic) IBOutlet UIButton *btnAddUser;

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
        return 45;
    }
    else return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setFont:[UIFont fontWithName:@"HeiTi SC" size:14]];
    UILabel *prop=[[UILabel alloc]init];
    [cell.contentView addSubview:prop];
    prop.frame=CGRectMake(60, 10, 260, 25);
    [prop setTextColor:[UIColor grayColor]];
    [prop setFont:[UIFont fontWithName:@"HeiTi SC" size:13]];
    prop.backgroundColor=[UIColor clearColor];
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
        prop.frame=CGRectMake(60, 0, 260, 45);
        [prop setNumberOfLines:0];
        prop.text=self.user.personalitySignature;
    }
    
    return cell;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.headImageView setClipsToBounds:YES];
    [self.headImageView.layer setCornerRadius:12];
    [self.headImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.headImageView.layer setBorderWidth:3.0];
    [self.btnAddUser setClipsToBounds:YES];
    [self.btnAddUser.layer setCornerRadius:5.0];
    [self refreshMessage];
	// Do any additional setup after loading the view.
}
-(void)callActionSheet{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加黑名单", nil];
    [actionSheet showInView:self.view];
    
}
- (void)addToBlack:(UIButton *)sender {
    [self.searchViewModel addBlackList:self.user];
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
    self.lbItel.text = [NSString stringWithFormat:@"%@",self.user.itelNum];
    
}
- (IBAction)addStranger:(UIButton *)sender {
    [self.searchViewModel addNewFriend:self.user];

    
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


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.headImageView setImageWithURL:[NSURL URLWithString:self.user.imageurl]];
    //[self.btnAddUser setUI];
    [self.btnAddUser setTitle:@"添加到通讯录" forState:UIControlStateNormal];
    [self.btnAddUser setTitle:@"添加到通讯录" forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(callActionSheet)];
    //[self.headImageView setRect:2.0 cornerRadius:self.headImageView.frame.size.width/6.0 borderColor:[UIColor whiteColor]];
    
  
    //[self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   
   
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)dealloc{
    NSLog(@"strangerVC被销毁了");
}
@end
