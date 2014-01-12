//
//  BlackListViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-20.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "BlackListViewController.h"
#import "ItelBook.h"
#import "ItelAction.h"
#import "blackCell.h"
@interface BlackListViewController ()
@property (nonatomic,strong) ItelBook *blackList;
@end

@implementation BlackListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [[self.blackList getAllKeys] count];
}

- (blackCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"blackCell";
    blackCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ItelUser *user=[self.blackList userAtIndex:indexPath.row];
    [cell setUser:user];
        
    return cell;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(blackListNotification:) name:@"getBlackList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(delNotification:) name:@"removeBlack" object:nil];
    [[ItelAction action] getItelBlackList:0];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)blackListNotification:(NSNotification*)notification{
    self.blackList=[[ItelAction action] blackList];
    [self.tableView reloadData];
}
-(void)delNotification:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"] boolValue];
    if (isNormal) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"移除成功" message:nil delegate:nil cancelButtonTitle:@"返回" otherButtonTitles:nil];
        [alert show];
        self.blackList=[[ItelAction action]blackList];
        [self.tableView reloadData];
    }
}
@end
