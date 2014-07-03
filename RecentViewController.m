//
//  RecentViewController.m
//  itelNSC
//
//  Created by nsc on 14-7-3.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RecentViewController.h"
#import "DBService.h"
#import "MaoAppDelegate.h"
#import "RecentCell.h"
#import "ItelUser+CRUD.h"
#import "Recent.h"
#import <UIImageView+AFNetworking.h>
@interface RecentViewController ()

@end

@implementation RecentViewController



- (void) setupFetchViewController{
    
    if ([DBService defaultService].managedObjectContext) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
        MaoAppDelegate *delegate=[UIApplication sharedApplication].delegate;
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                      [NSPredicate predicateWithFormat:@"targetItel"] ,[NSPredicate predicateWithFormat:@"hostItel = %@",[delegate.loginInfo objectForKey:@"itel"]]                                                                                  ]];
        request.predicate = predicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[DBService defaultService].managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self insertFake];
    [self setupFetchViewController];
    // Do any additional setup after loading the view.
}
-(RecentCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     RecentCell *cell= [tableView dequeueReusableCellWithIdentifier:@"RecentCell"];
    
    Recent *recent=[self.fetchedResultsController objectAtIndexPath:indexPath];
    ItelUser *user=recent.targetUser;
    [cell.imgHeader setImageWithURL:[NSURL URLWithString:user.imageurl]];
    cell.nickName.text=user.nickName;
    cell.peerItel.text=user.itelNum;
    
    return cell;
}
-(void)insertFake{
    NSArray *array=@[@"100",@"666666",@"1008611",@"101"];
    for (NSString *itel in array) {
        NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
        MaoAppDelegate *delegate=[UIApplication sharedApplication].delegate;
        NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Recent"];
        request.predicate=[NSPredicate predicateWithFormat:@"hostItel = %@ AND targerItel = %@",[delegate.loginInfo objectForKey:@"itel"],itel];
        request.sortDescriptors=@[@""]
        
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
