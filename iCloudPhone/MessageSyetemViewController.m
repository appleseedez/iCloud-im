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
@interface MessageSyetemViewController ()
@property (nonatomic,strong) NSArray *messageList;
@property (nonatomic,strong) NSString *currItel;
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
    
    cell.lbBody.text=message.body;
    cell.lbDate.text=message.date;
    NSString *imageUrl=message.sender.imageurl;
    [cell.imgPhoto setImageWithURL:[NSURL URLWithString: imageUrl ] placeholderImage:[UIImage imageNamed:@"头像.png"]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"接受邀请",@"忽略邀请",nil];
    self.currItel=((Message*)[self.messageList objectAtIndex:indexPath.row]).sender.itelNum;
    //actionSheet.cancelButtonIndex=2;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
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
    
    [[ItelAction action] acceptFriendIvication:self.currItel status:status];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"getNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showResult:) name:@"acceptFriends" object:nil];
    [[ItelAction action] getNewMessage];
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
