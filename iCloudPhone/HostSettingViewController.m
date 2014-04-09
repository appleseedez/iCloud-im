//
//  HostSettingViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostSettingViewController.h"
#import "HostCell.h"
#import "ItelViewModelManager.h"
#import "UIImage+Compress.h"
#import "HostItelUser.h"
#import <QuartzCore/QuartzCore.h>
#import "ItelAction.h"
#import "UIImageView+AFNetworking.h"
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
   
    NSString *cellIdentifier=indexForSting(indexPath) ;
    UITableViewCell <HostCell>*cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
   
    return cell;
}

@implementation HostSettingViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"modifyHost" object:nil];
    [self refresh];
}
-(void)refresh{
    [self.tableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.tableView.frame=CGRectMake(0, 0, 320, 450);
    RACSignal *dataSourceSignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACSubject *datas=[ItelViewModelManager defaultManager].hostModel.outSubject;
        [subscriber sendNext:datas];
        return nil;
    }]flatten];
        [dataSourceSignal subscribeNext:^(id x) {
            NSLog(@"%@",x);
            [self.tableView reloadData];
        }];
    

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
    
    NSLog(@"压缩后图片大小：%d",compressed.length);
   
    
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
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0||indexPath.section==1) {
        return 49;
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell <HostCell> *cell=(UITableViewCell<HostCell>*)getCellWithIndexPath(indexPath, tableView);
    HostItelUser *host=[[ItelAction action] getHost];
    [cell setPro:host];
     
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
