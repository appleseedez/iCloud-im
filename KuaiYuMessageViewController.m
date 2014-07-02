//
//  KuaiYuMessageViewController.m
//  itelNSC
//
//  Created by nsc on 14-6-30.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "KuaiYuMessageViewController.h"
#import "DBService.h"
#import <CoreData/CoreData.h>
#import "MessageKuaiyuCell.h"
#import "Message.h"
#import "MaoAppdelegate.h"
@interface KuaiYuMessageViewController ()

@end

@implementation KuaiYuMessageViewController

- (void) setupFetchViewController{
    
    if ([DBService defaultService].managedObjectContext) {
        MaoAppDelegate *delegate=[UIApplication sharedApplication].delegate;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItelMessage"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"isNew" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:nil]];
        
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                      [NSPredicate predicateWithFormat:@"type = %@",@"14"] ,[NSPredicate predicateWithFormat:@"hostItel = %@",[delegate.loginInfo objectForKey:@"itel"]]                                                                                  ]];
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
    [self setupFetchViewController];
    // Do any additional setup after loading the view.
}
-(MessageKuaiyuCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageKuaiyuCell *cell=[tableView dequeueReusableCellWithIdentifier:@"mesKuaiyuCell"];
    Message *message=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.lbTitle.text=message.title;
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    cell.lbDate.text=[formatter stringFromDate:message.date];
    cell.lbContent.text=message.content;
    cell.imgLogo.isNew=message.isNew;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Message *msg =  [self.fetchedResultsController objectAtIndexPath:indexPath];
    msg.isNew=@(NO);
    [[DBService defaultService].managedObjectContext save:nil];
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    id object= [self.fetchedResultsController objectAtIndexPath:indexPath];
    [[DBService defaultService] deletObject:object inContext:[DBService defaultService].managedObjectContext];
    [[DBService defaultService].managedObjectContext save:nil];
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
