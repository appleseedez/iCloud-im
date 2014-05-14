//
//  AddressBookTableViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "AddressBookTableViewController.h"
#import "AddressService.h"
#import "AddressCell.h"
#import "ContactViewModel.h"
#import "PeopleViewController.h"
#import "ItelUser+CRUD.h"
#import "AddressUser.h"

@interface AddressBookTableViewController ()

@end

@implementation AddressBookTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    PeopleViewController *pVC=self.navigationController.childViewControllers[0];
    self.contactViewModel=pVC.contactViewModel;
    self.service=[AddressService defaultService];
    __weak id weakSelf=self;
      [RACObserve(self, service.addressList) subscribeNext:^(id x) {
          __strong AddressBookTableViewController *strongSelf=weakSelf;
          dispatch_async(dispatch_get_main_queue(), ^{
               [strongSelf.tableView reloadData];
          });
         
      }];
    //监听hud
    [RACObserve(self, contactViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong AddressBookTableViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"加载中";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.service.addressList count];;
}


- (AddressCell  *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell" ];
    
    AddressUser *user=[self.service.addressList objectAtIndex:indexPath.row];
    [cell loadWithUser:user];
    cell.delegate=self;
    return cell;
}
-(void)addUser:(ItelUser*)user{
    [self.contactViewModel addNewFriend:user];
}
-(void)sendMessage:(AddressUser*)user{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != Nil) {
        if ([messageClass canSendText]) {
            [self displaySMSComposerSheet:user.phone];
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
-(void)displaySMSComposerSheet:(NSString*)number {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        
        picker.body=@"我注册了云电话，可以免费视频通话哦，赶快注册一个给我打视频电话吧~~~app store输入itel找到云电话即可下载";
        NSArray *array = @[number];
        picker.recipients = array;
        [self.navigationController presentViewController:picker animated:YES completion:^{
            
        }];
        
        
    }
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
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
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)dealloc{
    NSLog(@"addessBookVC被销毁了");
}
@end
