//
//  List115ViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "List115ViewController.h"
#import "NX115Cell.h"
#import "Detail115ViewController.h"
#import "Manager115.h"
@interface List115ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;

@end

@implementation List115ViewController

- (IBAction)searchButtonClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    [[Manager115 defaultManager] search115:self.txtSearch.text];
}
-(void)goForewardStep:(id)userInfo{
    self.arrList=[userInfo objectForKey:@"list"];
    [self.tableView reloadData];
}
-(NSArray*)notifications{
    return @[@"115search"];
}
- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *title=[[UILabel alloc]init];
    title.text = @"115 企业黄页";
    title.font=[UIFont fontWithName:@"HeiTi_SC" size:28];
    title.frame=CGRectMake(0, 0, 100, 40);
    title.textColor=[UIColor whiteColor];
    self.navigationItem.titleView=title;
	// Do any additional setup after loading the view.
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic=[self.arrList objectAtIndex:indexPath.row];
    Detail115ViewController *detailVC=[self.storyboard instantiateViewControllerWithIdentifier:@"detail115"];
    detailVC.parameters=dic;
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrList count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NX115Cell *cell=[tableView dequeueReusableCellWithIdentifier:@"115cell"];
    NSDictionary *dic=[self.arrList objectAtIndex:indexPath.row];
    [cell setPro:dic];
    return cell;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
@end
