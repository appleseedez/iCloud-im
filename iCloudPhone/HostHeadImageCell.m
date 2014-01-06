//
//  HostHeadImageCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostHeadImageCell.h"
#import "HostSettingViewController.h"
#import "UIImageView+AFNetworking.h"
@implementation HostHeadImageCell

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
-(void)showSettingView:(UIViewController <UIActionSheetDelegate>*)viewController{
    

    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:viewController cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取" ,nil];
    actionSheet.delegate=viewController;
    [actionSheet showInView:viewController.view];
}
-(void)setPro:(HostItelUser *)host{
    [self.betterFaceImage setImageWithURL:[NSURL URLWithString:host.imageUrl] placeholderImage:[UIImage imageNamed:@"头像.png"]];
    
}
@end
