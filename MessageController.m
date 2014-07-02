//
//  MessageController.m
//  itelNSC
//
//  Created by nsc on 14-6-30.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MessageController.h"
#import "Message.h"
#import "DBService.h"
#import "MaoAppDelegate.h"
#import "MessageImageView.h"
@interface MessageController ()
@property (weak, nonatomic) IBOutlet MessageImageView *imgSystem;
@property (weak, nonatomic) IBOutlet MessageImageView *imgKuaiyu;
@property (weak, nonatomic) IBOutlet MessageImageView *imgFirend;
@property (nonatomic)  NSFetchedResultsController *systemController;
@property (nonatomic)  NSFetchedResultsController *kuaiyuController;
@property (weak, nonatomic) IBOutlet UILabel *lbSystem;
@property (weak, nonatomic) IBOutlet UILabel *lbKuaiyu;
@property (weak, nonatomic) IBOutlet UILabel *lbFriend;
@property (nonatomic)  NSFetchedResultsController *friendController;
@end

@implementation MessageController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
   [self checkNew];
    
    
   // [self loadFake];
    
    
    
    
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabbar" object:nil];
}
-(void)checkNew{
    MaoAppDelegate *delegate=[UIApplication sharedApplication].delegate;
    //是否有新的系统消息
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"ItelMessage"];
    request.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"isNew" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:nil]];;
   request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                            [NSPredicate predicateWithFormat:@"type = %@ OR type= %@ OR type = %@",@"00",@"02",@"03"] ,[NSPredicate predicateWithFormat:@"hostItel = %@",[delegate.loginInfo objectForKey:@"itel"]]]];
    NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
    self.systemController=[[NSFetchedResultsController alloc]initWithFetchRequest:[request copy] managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.systemController.delegate=self;
    [self.systemController performFetch:nil];
    NSArray *systemResult=  [self.systemController fetchedObjects];
   
    if ([systemResult count]) {
         Message *systemMes=systemResult[0];
    
        if ([systemMes.isNew boolValue]) {
            
            self.imgSystem.isNew=@(YES);
        }else{
            self.imgSystem.isNew=@(NO);
        }
        self.lbSystem.text=systemMes.content;
    }else{
        self.lbSystem.text=@"";
    }
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                             [NSPredicate predicateWithFormat:@"type = %@",@"01"] ,[NSPredicate predicateWithFormat:@"hostItel = %@",[delegate.loginInfo objectForKey:@"itel"]]]];
    self.friendController=[[NSFetchedResultsController alloc]initWithFetchRequest:[request copy] managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.friendController.delegate=self;
    [self.friendController performFetch:nil];
    NSArray *firendResult = [self.friendController fetchedObjects];
   
    if ([firendResult count]) {
        Message *friendMes=firendResult[0];
        
        if ([friendMes.isNew boolValue]) {
            
            self.imgFirend.isNew=@(YES);
        }else{
            self.imgFirend.isNew=@(NO);
        }
        self.lbFriend.text=friendMes.content;
    }else{
        self.lbFriend.text=@"";
    }
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                             [NSPredicate predicateWithFormat:@"type = %@",@"14"] ,[NSPredicate predicateWithFormat:@"hostItel = %@",[delegate.loginInfo objectForKey:@"itel"]]]];
    
    self.kuaiyuController=[[NSFetchedResultsController alloc]initWithFetchRequest:[request copy] managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.kuaiyuController.delegate=self;
    [self.kuaiyuController performFetch:nil];
    NSArray *kuaiyuResult = [self.kuaiyuController fetchedObjects];
    if ([kuaiyuResult count]) {
        Message *kuaiyuMes=kuaiyuResult[0];
    
    if ([kuaiyuMes.isNew boolValue]) {
        self.imgKuaiyu.isNew=@(YES);
    }else{
        self.imgKuaiyu.isNew=@(NO);
    }
        self.lbKuaiyu.text=kuaiyuMes.content;
    }else{
        self.lbKuaiyu.text=@"";
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    if ([self.systemController.fetchedObjects count]) {
        Message *systemMes=self.systemController.fetchedObjects[0];
        
        if ([systemMes.isNew boolValue]) {
            
            self.imgSystem.isNew=@(YES);
        }else{
            self.imgSystem.isNew=@(NO);
        }
        self.lbSystem.text=systemMes.content;
    }else{
        self.lbSystem.text=@"";
    }

    if ([self.friendController.fetchedObjects count]) {
        Message *friendMes=self.friendController.fetchedObjects[0];
        
        if ([friendMes.isNew boolValue]) {
            
            self.imgFirend.isNew=@(YES);
        }else{
            self.imgFirend.isNew=@(NO);
        }
        self.lbFriend.text=friendMes.content;
    }else{
        self.lbFriend.text=@"";
    }
    if ([self.kuaiyuController.fetchedObjects count]) {
        Message *kuaiyuMes=self.kuaiyuController.fetchedObjects[0];
        
        if ([kuaiyuMes.isNew boolValue]) {
            self.imgKuaiyu.isNew=@(YES);
        }else{
            self.imgKuaiyu.isNew=@(NO);
        }
        self.lbKuaiyu.text=kuaiyuMes.content;
    }else{
        self.lbKuaiyu.text=@"";
    }
}

-(void)loadFake{
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"ItelMessage"];
    NSDictionary *hostUser=((MaoAppDelegate*)[UIApplication sharedApplication].delegate).loginInfo;
    
    
    request.predicate=[NSPredicate predicateWithFormat:@"type = %@",@"00"];
    NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
    NSArray *result=  [context executeFetchRequest:request error:nil];
    
    NSArray *types=@[@"00",@"01",@"02",@"03",@"14",@"14",@"01",@"01",@"14",@"01",@"01"];
    if (![result count]) {
        for (int i=0; i<11; i++) {
            Message *msg =  [NSEntityDescription insertNewObjectForEntityForName:@"ItelMessage" inManagedObjectContext:context];
            msg.title=[NSString stringWithFormat:@"系统消息%d",i];
            msg.hostItel=[hostUser objectForKey:@"itel"];
            msg.content=@"这是一条系统消息";
            msg.type=[types objectAtIndex:i];
            msg.date=[NSDate dateWithTimeIntervalSince1970:32002*i];
            msg.isNew=@(YES);
        }
        [context save:nil];
    }

}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
}


@end
