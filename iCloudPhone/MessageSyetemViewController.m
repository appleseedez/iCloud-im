//
//  MessageSyetemViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-30.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "MessageSyetemViewController.h"
#import "ItelAction.h"
#import "MessageCell.h"
#import "Message.h"
#import "UIImageView+AFNetworking.h"
#import "IMCoreDataManager.h"
@interface MessageSyetemViewController ()
@property (nonatomic,strong) NSArray *messageList;
@property (nonatomic,strong) NSString *currItel;
@property (nonatomic,strong) Message *currMessage;
@end

@implementation MessageSyetemViewController
-(NSArray*)messageList{
    if (_messageList==nil) {
        _messageList=[[ItelAction action] getMessageList];
    }
    return _messageList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
        return 1;
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [self.messageList count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"messageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    Message *message=[self.messageList objectAtIndex:indexPath.row];
    cell.lbTittle.text= message.sender.nickName;
    if (!cell.lbTittle.text.length) {
        cell.lbTittle.text=message.sender.itelNum;
    }
    [cell.imgPhoto setRect:2 cornerRadius:cell.imgPhoto.frame.size.height/6 borderColor:[UIColor whiteColor]];
    cell.lbBody.text=message.body;
    cell.lbDate.text=message.date;
    NSString *imageUrl=message.sender.imageurl;
    [cell.imgPhoto setImageWithURL:[NSURL URLWithString: imageUrl ] placeholderImage:[UIImage imageNamed:@"头像.png"]];
    if ([message.isRead boolValue]) {
        cell.newMessage.alpha=0;
    }
    else{
        cell.newMessage.alpha=1;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"接受邀请",@"忽略邀请",nil];
    Message *message=[self.messageList objectAtIndex:indexPath.row];
    self.currItel=message.sender.itelNum;
    self.currMessage=message;

    BOOL isRead=[message.isRead boolValue];
    if (isRead==NO) {
        [actionSheet showInView:self.view];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"已处理消息" message:@"您已经处理过该消息，不能再次处理" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
    
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    NSString *status=nil;
    if (buttonIndex==2) {
        return;
    }
    
   else if (buttonIndex==0) {
         //接受邀请接口
        status=@"1";
       
    }
    else if(buttonIndex==1){
        status=@"3";
        
    }
    self.currMessage.isRead=[NSNumber numberWithBool:YES];
    [[ItelAction action] acceptFriendIvication:self.currItel status:status];
     [self.tableView reloadData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"getNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showResult:) name:@"acceptFriends" object:nil];
    [[ItelAction action] getNewMessage];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTab" object:nil userInfo:@{@"hidden":@"0"}];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)showResult:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    if (isNormal) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"操作失败" message:[notification.userInfo objectForKey:@"reason"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}
-(void)refresh:(NSNotification*)notification{
    self.messageList =[[ItelAction action]getMessageList];
    [self.tableView reloadData];
}
@end
