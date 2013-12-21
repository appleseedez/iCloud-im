//
//  HostSexCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostSexCell.h"

@implementation HostSexCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)showSettingView:(UIViewController *)viewController{
    UIWindow *window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window=window;
    [window setWindowLevel:UIWindowLevelStatusBar];
    window.backgroundColor=[UIColor clearColor];
    window.alpha=1;
    UIButton *back=[[UIButton alloc]initWithFrame:window.bounds];
    back.backgroundColor=[UIColor grayColor];
    back.alpha=0.5;
    back.tag=25367;
    [back  addTarget:self action:@selector(sexSelect:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:back];
    UIButton *male=[[UIButton alloc]initWithFrame:CGRectMake(20, 200, 280, 40)];
    [male setTitle:@"男" forState:UIControlStateNormal];
    male.tag=25368;
    male.backgroundColor=[UIColor whiteColor];
    [male.titleLabel setTextColor:[UIColor blackColor]];
    [window addSubview:male];
    [male addTarget:self action:@selector(sexSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *female=[[UIButton alloc]initWithFrame:CGRectMake(20, 245, 280, 40)];
    [female setTitle:@"女" forState:UIControlStateNormal];
    female.tag=25369;
    female.backgroundColor=[UIColor whiteColor];
    [female.titleLabel setTextColor:[UIColor blackColor]];
    [window addSubview:female];
    [female addTarget:self action:@selector(sexSelect:) forControlEvents:UIControlEventTouchUpInside];
    [window setHidden:NO];
}

-(void)sexSelect:(UIButton*)sender{
    [self.window setHidden:YES];
    self.window=nil;
}
@end
