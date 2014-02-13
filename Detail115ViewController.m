//
//  Detail115ViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Detail115ViewController.h"
#import "Detail115Cell.h"
#import "NXImageView.h"
#import "UIImageView+AFNetworking.h"
#import "Button115.h"
#import "NSCAppDelegate.h"
#import "IMDailViewController.h"
@interface Detail115ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet NXImageView *logoImage;
@end

@implementation Detail115ViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (IBAction)dial:(id)sender {
    [self presentCallingView];
}
- (void) presentCallingView{
    
    NSCAppDelegate *delegate=(NSCAppDelegate*)[UIApplication sharedApplication].delegate ;
    [delegate.manager dial:[self.parameters objectForKey:@"itel"]];
    //[delegate.manager dial:@"911"];
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Detail115Cell *cell=[tableView dequeueReusableCellWithIdentifier:@"detail115cell"];
    NSDictionary *pro=nil;
    
    switch (indexPath.row) {
        case 0:
            pro=@{@"title": @"iTel号码：",@"detail":[self.parameters valueForKey:@"itel"]};
            break;
        case 1:
            pro=@{@"title": @"电子邮箱：",@"detail":[self.parameters valueForKey:@"mail"]};
            break;
        case 2:
            pro=@{@"title": @"联系电话：",@"detail":[self.parameters valueForKey:@"phone"]};
            break;
        case 3:
            pro=@{@"title": @"主页：",@"detail":@""};
            break;
        case 4:
            pro=@{@"title": @"企业简介：",@"detail":[self.parameters valueForKey:@"recommend"]};
            break;
            
        default:
            break;
    }
    
    [cell setPro:pro];
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lbName.text=[self.parameters objectForKey:@"nick_name"];
    NSString *photo=[self.parameters objectForKey:@"photo_file_name"];
    if ([photo isEqual:[NSNull null]]) {
        
    }else{
        [self.logoImage setImageWithURL:[NSURL URLWithString:photo] ];
    }
    UILabel *title=[[UILabel alloc]init];
    title.text = @"115 企业黄页";
    title.font=[UIFont fontWithName:@"HeiTi_SC" size:28];
    title.frame=CGRectMake(0, 0, 100, 40);
    title.textColor=[UIColor whiteColor];
    self.navigationItem.titleView=title;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(pop)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    for(Button115 *btn in self.view.subviews ){
        if ([btn isKindOfClass:[Button115 class]]) {
            [btn setUI];
        }
    }
	// Do any additional setup after loading the view.
}
-(void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
