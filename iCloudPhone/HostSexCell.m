//
//  HostSexCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostSexCell.h"
#import "ItelAction.h"
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
    UIButton *male=[UIButton buttonWithType:UIButtonTypeSystem];
    male.frame=CGRectMake(20, 200, 280, 45);
        male.tag=25368;
    male.backgroundColor=[UIColor whiteColor];
    [male.titleLabel setTextColor:[UIColor blackColor]];
    [window addSubview:male];
    [male addTarget:self action:@selector(sexSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *nan=[[UIImageView alloc]initWithFrame:CGRectMake(90, 12, 16, 16)];
    nan.image=[UIImage imageNamed:@"male"];
    [male addSubview:nan];
    [male setTitle:@"男" forState:UIControlStateNormal];

    
    UIButton *female=[UIButton buttonWithType:UIButtonTypeSystem];
    female.frame=CGRectMake(20, 245, 280, 45);
    female.tag=25369;
    female.backgroundColor=[UIColor whiteColor];
    [female.titleLabel setTextColor:[UIColor blackColor]];
    [window addSubview:female];
    [female addTarget:self action:@selector(sexSelect:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *nv=[[UIImageView alloc]initWithFrame:CGRectMake(90, 12, 16, 16)];
    nv.image=[UIImage imageNamed:@"female"];
    [female addSubview:nv];
     [female setTitle:@"女" forState:UIControlStateNormal];
    
    [male.layer setCornerRadius:10];
    [female.layer setCornerRadius:10];
    [window setHidden:NO];
}

-(void)sexSelect:(UIButton*)sender{
    [self.window setHidden:YES];
    NSString *sex=nil;
    if (sender.tag==25368) {
         sex = @"0";
    }
    else if(sender.tag==25369){
        sex =@"1";
    }
    if(sex){
        [[ItelAction action] modifyPersonal:@"sex" forValue:sex];
    }
  }

-(void)setPro:(HostItelUser *)host{
    if (host.sex) {
        self.sexImage.image=[UIImage imageNamed:@"female"];
    }
    else self.sexImage.image=[UIImage imageNamed:@"male"];
}
@end
