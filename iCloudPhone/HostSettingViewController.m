//
//  HostSettingViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostSettingViewController.h"
#import "HostCell.h"
#import  "UIImageView+BetterFace.h"
#import "UIImage+Compress.h"
#import "HostItelUser.h"
#import <QuartzCore/QuartzCore.h>
#import "ItelAction.h"
@interface HostSettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) HostItelUser *hostUser;

@end
NSString * indexForSting(NSIndexPath* indexPath){
    NSDictionary *dic=@{@"1_1": @"AvatarImageCell",
                        @"2_1": @"sign",
                        @"3_1": @"nickname",
                        @"3_2": @"sex",
                        @"3_3": @"birthday",
                        @"3_4": @"address",
                        @"4_1": @"telephone",
                        @"4_2": @"email",
                        @"4_3": @"QQ",};
    NSString *indexString=[NSString stringWithFormat:@"%d_%d",indexPath.section+1,indexPath.row+1];
     NSString *cellIdentifier=[dic objectForKey:indexString] ;
    return cellIdentifier;
}

UITableViewCell <HostCell> *getCellWithIndexPath(NSIndexPath *indexPath,UITableView *tableView){
   
    NSString *cellIdentifier=indexForSting(indexPath) ;    UITableViewCell <HostCell>*cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
   
    return cell;
}

@implementation HostSettingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.betterFaceImage.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.betterFaceImage.layer setBorderWidth:0.5f];
    [self.betterFaceImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.betterFaceImage setClipsToBounds:YES];
    [self.betterFaceImage setNeedsBetterFace:YES];
    [self.betterFaceImage setFast:YES];
    self.tableView.frame=CGRectMake(0, 0, 320, 450);
    
    

	// Do any additional setup after loading the view.
}
- (void)getCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"相机不可用" message:@"该设备相机不可用" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
    else {
        UIImagePickerController *pick=[[UIImagePickerController  alloc]init];
        pick.delegate=self;
       
        pick.allowsEditing=YES;
        [pick setSourceType:UIImagePickerControllerSourceTypeCamera];
         pick.cameraDevice=UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:pick animated:YES completion:^{
            
        }];
    }
}
-(void)getPhoto{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"相册不可用" message:@"该设备相册不可用" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
    else {
        UIImagePickerController *pick=[[UIImagePickerController  alloc]init];
        pick.delegate=self;
        
        pick.allowsEditing=YES;
        [pick setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        [self presentViewController:pick animated:YES completion:^{
            
        }];
    }

}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //原始图片
    UIImage *OriginalImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];

    //压缩质量
    NSData *compressed=UIImageJPEGRepresentation([OriginalImage compressedImage],0.5);
    
    UIImage *compressedImage=[UIImage imageWithData:compressed];
    
    [self.betterFaceImage setBetterFaceImage:compressedImage];
   
    NSData *face = UIImagePNGRepresentation(self.betterFaceImage.image);
    NSLog(@"2 处理以后图片大小：%ldByte",(long)face.length);
    [[ItelAction action] uploadImage:compressedImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num=0;
    switch (section) {
        case 0:
            num=1;
            break;
        case 1:
            num=1;
            break;
        case 2:
            num=4;
            break;
        case 3:
            num=3;
            break;

        default:
            break;
    }
    return num;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 18;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 80;
    }
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=(UITableViewCell*)getCellWithIndexPath(indexPath, tableView);
    return cell;
}
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell <HostCell>*cell=(UITableViewCell<HostCell>*)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(showSettingView:)] ) {
        [cell showSettingView:self];
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            
            [self getCamera];
            break;
        case 1:
            [self getPhoto];
            break;
            
        default:
            break;
    }
}
@end
