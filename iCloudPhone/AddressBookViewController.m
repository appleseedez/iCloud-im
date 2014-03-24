//
//  AddressBookViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-17.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "AddressBookViewController.h"
#import "PersonInAddressBook.h"
#import  "AddressBookCell.h"
#import "ItelAction.h"
#import "StrangerCell.h"
@interface AddressBookViewController ()
@property (nonatomic,strong) AddressBook *address;

@end

@implementation AddressBookViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}


#pragma mark -tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
    return [[self.address getAllKeys] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"我的通讯录";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (AddressBookCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"addressBookCell";
    AddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AddressBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    if ([[self.address getAllKeys] count]-1>=indexPath.row) {
        NSString *key=[[self.address getAllKeys] objectAtIndex:indexPath.row];
        PersonInAddressBook *person= (PersonInAddressBook*)[self.address userForKey:key];
        
        [cell setCell:person];
        
        cell.delegate=self;
    }
    
        //config the cell
    return cell;
    
}
-(void)addFriends:(InviteButton *)sender{
    PersonInAddressBook *person=(PersonInAddressBook*)sender.userInfo;
    if (person.itelUser!=nil) {
        [[ItelAction action] inviteItelUserFriend:person.itelUser.itelNum];
    }
    
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (void)invitePerson:(InviteButton*)sender{
    PersonInAddressBook *person=(PersonInAddressBook*)sender.userInfo;
    if (person.itelUser==nil) {
         [self showSMSPicker:person.tel];
    }

    
}
#pragma mark - 监听通讯录通知
//void *PhoneBook=(void*)&PhoneBook;
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didAddFriend:) name:@"inviteItelUser" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddress:) name:@"addressLoadingFinish" object:nil];
   self.address= [[ItelAction action] getAddressBook];
    
}
-(void)didAddFriend:(NSNotification*)notification{
    BOOL isNormal = [[notification.userInfo objectForKey:@"isNormal"]boolValue];
    NSString *result=nil;
    NSString *tittle=nil;
    if (isNormal) {
        result=@"请求发送成功 等待对方确认";
        tittle=@"成功";
    }
    else {
       result = [notification.userInfo objectForKey:@"reason"];
        tittle=@"失败";
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:tittle message:result delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
    alert=nil;
}

-(void)showAddress:(NSNotification*)notification{
    self.address=(AddressBook*)notification.object;
    [self.tableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 调用短信接口
- (void)showSMSPicker :(NSString*)number{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
        if ([messageClass canSendText]) {
            [self displaySMSComposerSheet:number];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备没有短信功能" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
            [alert show];
            
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"iOS版本过低,iOS4.0以上才支持程序内发送短信" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
        [alert show];
}
}
- (void)displaySMSComposerSheet:(NSString*)number {
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    picker.body=@"我注册了云电话，可以免费视频通话哦，赶快注册一个给我打视频电话吧~~~app store输入itel找到云电话即可下载";
    NSArray *array = @[number];
    picker.recipients = array;
    [self.navigationController presentViewController:picker animated:YES completion:^{
        
    }];
    
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"发送取消");
            break;
        case MessageComposeResultSent:
           NSLog(@"发送成功");
            break;
        case MessageComposeResultFailed:
            [[[UIAlertView alloc] initWithTitle:@"发送失败" message:@"发送失败" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil] show];
            
            break;
        default:
            NSLog(@"发送失败");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
