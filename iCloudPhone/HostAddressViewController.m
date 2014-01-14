//
//  HostAddressViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-1-14.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "HostAddressViewController.h"
#import "IMCoreDataManager.h"
#import "FMDatabase.h"
#import "Area.h"
#import "HostSecondAddressViewController.h"
@interface HostAddressViewController ()

@end

@implementation HostAddressViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:@"省级"];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  
    [self setupFetchViewController];
}
- (void) setupFetchViewController{
    if ([IMCoreDataManager defaulManager].managedObjectContext) {
        // 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO selector:nil]];
        request.predicate = [NSPredicate predicateWithFormat:@"parentId = %@ AND capital = 0",[NSNumber numberWithInt:0]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[IMCoreDataManager defaulManager].managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HostSettingAddressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Area *area=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=area.name;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
     Area *area=[self.fetchedResultsController objectAtIndexPath:indexPath];
    HostSecondAddressViewController *nextList =  [self.storyboard instantiateViewControllerWithIdentifier:@"hostSecondAddressView"];
    nextList.parentArea=area;
    [self.navigationController pushViewController:nextList animated:YES];
}
@end
