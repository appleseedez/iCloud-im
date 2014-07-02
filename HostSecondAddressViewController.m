//
//  HostSecondAddressViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-1-14.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "HostSecondAddressViewController.h"
#import "DBService.h"
#import "MoreViewModel.h"

@interface HostSecondAddressViewController ()

@end

@implementation HostSecondAddressViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.parentArea.areaId intValue]<=99) {
        [self setTitle:@"市级"];
    }
    else if([self.parentArea.areaId intValue]<=9999){
        [self setTitle:@"区县级"];
    }
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setupFetchViewController];
}
- (void) setupFetchViewController{
    if ([DBService defaultService].managedObjectContext) {
        // 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO selector:nil]];
        request.predicate = [NSPredicate predicateWithFormat:@"parentId = %@",self.parentArea.areaId];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[DBService defaultService].managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"secondAddressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Area *area=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=area.name;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    Area *area=[self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([self.parentArea.areaId intValue]<=99) {
               HostSecondAddressViewController *nextList =  [self.storyboard instantiateViewControllerWithIdentifier:@"hostSecondAddressView"];
        nextList.parentArea=area;
        nextList.moreViewModel=self.moreViewModel;
        [self.navigationController pushViewController:nextList animated:YES];
    }
    else if([self.parentArea.areaId intValue]<=9999){
             [self.navigationController dismissViewControllerAnimated:YES completion:^{
                   //这里请求
                 [self.moreViewModel modifyHoseSetting:@"area_code" value:[NSString stringWithFormat:@"%@",area.areaId]];
             }];
        
        
            }

    
}

@end
