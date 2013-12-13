//
//  IMRecentContactListViewController.m
//  im
//
//  Created by Pharaoh on 13-12-6.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMRecentContactListViewController.h"
#import "IMRootTabBarViewController.h"
#import "IMDailViewController.h"
#import "IMManager.h"
@interface IMRecentContactListViewController ()
@property id<IMManager> manager;
@end

@implementation IMRecentContactListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setup];
}
//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//
//}
- (void)viewDidLoad
{
    NSLog(@"tableView的viewDidLoad方法被调用");
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - private 
- (void) setup{
    IMRootTabBarViewController* root =(IMRootTabBarViewController*)self.tabBarController;
    self.manager = root.manager;
    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
    IMDailViewController* dialViewController = (IMDailViewController*) [sb instantiateViewControllerWithIdentifier:DIAL_PAN_VIEW_CONTROLLER_ID];
    dialViewController.manager = self.manager;
    [self presentViewController:dialViewController animated:YES completion:nil];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
