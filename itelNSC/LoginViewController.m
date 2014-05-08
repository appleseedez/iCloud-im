//
//  LoginViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "LoginTableViewCell.h"
#import "RegTypeViewController.h"
#import "MaoAppDelegate.h"
#import <UIImageView+AFNetworking.h>
@interface LoginViewController ()
@property (nonatomic,weak) IBOutlet UITextField *txtUserCloudNumber;
@property (nonatomic,weak) IBOutlet UITextField *txtUserPassword;
@property (nonatomic,weak) IBOutlet UIButton *btnShowList;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UIView *contentView;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,weak) IBOutlet UIButton *btnLogin;
 @end

@implementation LoginViewController
static const NSInteger delButtonBase=10086;
static float tableViewHeight=135.0;
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    
    
    [self.imgHeader setClipsToBounds:YES];
    [self.imgHeader.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.imgHeader.layer setBorderWidth:3];
    [self.imgHeader.layer setCornerRadius:12];
    self.hud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.btnLogin setClipsToBounds:YES];
    [self.btnLogin.layer setCornerRadius:5];
    //监听 显示隐藏用户列表
    self.viewModel=[[LoginViewModel alloc]init];
    
    [RACObserve(self, viewModel.showTableView) subscribeNext:^(NSNumber *x) {
        BOOL showTableView=[x boolValue];
       
        if (showTableView) {
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.frame=CGRectMake(0, 0, self.tableView.frame.size.width, tableViewHeight);
                [self.btnShowList setImage:[UIImage imageNamed:@"btn_login_showList_up"] forState:UIControlStateNormal];

            } completion:^(BOOL finished) {
                self.contentView.userInteractionEnabled=YES;
                NSLog(@"%f",self.tableView.frame.size.height);
            }];
            
        }else{
           [UIView animateWithDuration:0.3 animations:^{
               self.tableView.frame=CGRectMake(0, -self.tableView.frame.size.height, self.tableView.frame.size.width, tableViewHeight);
               [self.btnShowList setImage:[UIImage imageNamed:@"btn_login_showList_down"] forState:UIControlStateNormal];
           } completion:^(BOOL finished) {
               self.contentView.userInteractionEnabled=NO;
           }];
            
           
        }
        
    }];
    
    //事件 显示隐藏用户列表
    [[self.btnShowList rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        BOOL showTableView=[self.viewModel.showTableView boolValue];
        self.viewModel.showTableView=@(!showTableView);
    }];
    
    //监听 用户名 itel
    [RACObserve(self, viewModel.itel) subscribeNext:^(NSString *x) {
        self.txtUserCloudNumber.text=x;
    }];
    [RACObserve(self, viewModel.password) subscribeNext:^(NSString *x) {
        self.txtUserPassword.text=x;
    }];
    //监听 hud
    [RACObserve(self, viewModel.busy) subscribeNext:^(NSNumber *x) {
        BOOL showHud=[x boolValue];
        if (showHud) {
           MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"登录中...";
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];        }
    }];
    
    //事件 点击登陆
    [[self.btnLogin rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        self.viewModel.itel=self.txtUserCloudNumber.text;
        self.viewModel.password=self.txtUserPassword.text;
        [self.viewModel login];
    }];
    //监听 tableView
     [RACObserve(self, viewModel.backUsers) subscribeNext:^(NSArray *x) {
         self.btnShowList.enabled=(BOOL)[x count];
         if ([x count]<=3) {
             tableViewHeight=[x count]*45.0;
             NSLog(@"%f",self.tableView.frame.size.height);
         }
               [self.tableView reloadData];
         
     }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    self.viewModel.showTableView=@(NO);
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==self.txtUserCloudNumber) {
        self.txtUserCloudNumber.text=nil;
        self.txtUserPassword.text=nil;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==self.txtUserCloudNumber) {
        if (range.location>=11) {
            return NO;
        }
        else return YES;
    }
    else if (textField==self.txtUserPassword){
        if (range.location>=20) {
            return NO;
        }
        else return YES;
    }
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conformKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:Nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)conformKeyBoard:(NSNotification*)notification{
    CGFloat keyBoardHeightDelta;
    
    NSDictionary *info= notification.userInfo;
    
    CGRect beginRect=[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    keyBoardHeightDelta=beginRect.origin.y-endRect.origin.y;
    
    [UIView animateWithDuration:0.30 delay:0.2 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.view.center=CGPointMake(self.view.center.x, self.view.center.y-keyBoardHeightDelta/2);
    } completion:^(BOOL finished) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel.backUsers count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LoginTableViewCell *cell=  [self.tableView dequeueReusableCellWithIdentifier:@"loginCell"];
    NSDictionary *dic =[self.viewModel.backUsers objectAtIndex:indexPath.row];
    
    cell.lbItel.text=[dic objectForKey:@"itel"];
   
    NSURL *imageUrl=[NSURL URLWithString:[dic objectForKey:@"image"]];
    [cell.imgHeader setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"logo_login_header"]];
    cell.btnDel.tag=delButtonBase+indexPath.row;
    [cell.btnDel addTarget:self action:@selector(delUser:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
      NSDictionary *dic= [self.viewModel.backUsers objectAtIndex:indexPath.row];
    NSString *itel=[dic objectForKey:@"itel"];
    NSString *password=[dic objectForKey:@"password"];
    self.viewModel.itel=itel;
    self.viewModel.password=password;
    self.viewModel.showTableView=@(NO);
}
-(void)delUser:(UIButton*)sender{
    NSMutableArray *arr=[self.viewModel.backUsers mutableCopy];
    [arr removeObjectAtIndex:sender.tag-delButtonBase];
    self.viewModel.backUsers=[arr copy];
    self.viewModel.showTableView=@(NO);
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    
    UINavigationController *nav=(UINavigationController*)segue.destinationViewController;
    UIViewController *VC=[nav.childViewControllers objectAtIndex:0];
    if ([VC isKindOfClass:[RegTypeViewController class]]) {
        ((RegTypeViewController*)VC).viewModel=self.viewModel;
        [[NSNotificationCenter defaultCenter] addObserver:self.viewModel selector:@selector(regSuccess:) name:@"registeSuccess" object:nil];
    }
   
    
}
@end
