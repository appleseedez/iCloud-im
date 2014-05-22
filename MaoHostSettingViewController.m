//
//  MaoHostSettingViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//
/*{
"area_code" = "-24181";
 birthday = "1983-03-19";
 domain = "211.149.144.15";
 "is_call" = 0;
 "is_scall" = 0;
 "is_search" = 0;
 "is_shake" = 1;
 "is_sms" = 0;
 "is_voi" = 1;
 itel = 2301031983;
 mail = "<null>";
 "nick_name" = " \U6d41\U6d6a\U7684\U732b";
 phone = 13012360815;
 "photo_file_name" = "http://115.28.21.131:8000/group1/M00/00/05/cxwVg1N0JnaAVeSxAAAm1zkKrKA.header";
"qq_num" = 41209919;
 sex = 0;
 userId = 258;
 "user_type" = 0;
 */
#import "MaoHostSettingViewController.h"
#import "MoreViewModel.h"
#import <UIImageView+AFNetworking.h>
#import "UIImage+Compress.h"
#import "MoreHostEditViewController.h"
#import "MoreHostSexView.h"
@interface MaoHostSettingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *lbSign;
@property (weak, nonatomic) IBOutlet UILabel *lbNickname;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UITextField *lbBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lbArea;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *lbEmail;
@property (weak, nonatomic) IBOutlet UILabel *lbQQ;
@property (strong, nonatomic) IBOutlet MoreHostSexView *sexSettingView;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;
@property (nonatomic,weak)  UIWindow *sexSettingWindow;
@end

@implementation MaoHostSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *birthdayView=[[[NSBundle mainBundle] loadNibNamed:@"MoreHostBirthdatView" owner:self options:nil] objectAtIndex:0];
    self.lbBirthday.inputView=birthdayView;
    [self setUI];
    
  __weak  id weakSelf=self;
       //监听 头像
    [RACObserve(self, moreViewModel.imgUrl)subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        if ([x length]) {
            [strongSelf.imgHead setImageWithURL:[NSURL URLWithString:x] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
        }
    }];
       //监听 签名
    [RACObserve(self, moreViewModel.sign) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbSign.text=x;
    }];
    //监听 昵称
    [RACObserve(self, moreViewModel.nickname) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbNickname.text=x;
    }];
    //监听 性别
    [RACObserve(self, moreViewModel.sex) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        if ([x boolValue]) {
            [strongSelf.imgSex setImage:[UIImage imageNamed:@"male"]];
        }else{
            [strongSelf.imgSex setImage:[UIImage imageNamed:@"female"]];
        }
    }];
    //监听 生日
    [RACObserve(self, moreViewModel.birthday) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbBirthday.text=x;
    }];
    //监听 所在地
    [RACObserve(self, moreViewModel.area) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbArea.text=x;
    }];
    //监听 手机
    [RACObserve(self, moreViewModel.phone) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbPhone.text=x;
    }];
    //监听 邮箱
    [RACObserve(self, moreViewModel.email) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbEmail.text=x;
    }];
    //监听 QQ
    [RACObserve(self, moreViewModel.qq) subscribeNext:^(NSString *x) {
    __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbQQ.text=x;
    }];
    //监听hud
    [RACObserve(self, moreViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
}
- (IBAction)birthdayFinish:(id)sender {
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *birthday=[formatter stringForObjectValue:self.birthdayPicker.date];
    [self.moreViewModel modifyHoseSetting:@"birthday" value:birthday];
 
    [self.lbBirthday resignFirstResponder];
}
- (IBAction)birthdayCancel:(id)sender {
    [self.lbBirthday resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==self.lbBirthday) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date= [formatter dateFromString:textField.text];
        if (date) {
            self.birthdayPicker.date=date;
        }
    }
}
-(void)getCamera{
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
-(void)getPhotoBook{
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
-(void)editImage{
    
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取", @"拍照",nil];
    [actionSheet showInView:self.view];
    __weak  id weakSelf=self;
    [[actionSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        if ([x longValue]==0) {
             //相册选取
            [strongSelf getPhotoBook];
        }else if ([x longValue]==1){
             //拍照
            [strongSelf getCamera];
        }
    }];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        [self editImage];
        /*{
         "area_code" = "-24181";
         birthday = "1983-03-19";
         domain = "211.149.144.15";
         "is_call" = 0;
         "is_scall" = 0;
         "is_search" = 0;
         "is_shake" = 1;
         "is_sms" = 0;
         "is_voi" = 1;
         itel = 2301031983;
         mail = "<null>";
         "nick_name" = " \U6d41\U6d6a\U7684\U732b";
         phone = 13012360815;
         "photo_file_name" = "http://115.28.21.131:8000/group1/M00/00/05/cxwVg1N0JnaAVeSxAAAm1zkKrKA.header";
         "qq_num" = 41209919;
         sex = 0;
         userId = 258;
         "user_type" = 0;
         */
    }else if (indexPath.section==1){
       MoreHostEditViewController *editVC= [self.storyboard instantiateViewControllerWithIdentifier:@"HostEditVC"];
        editVC.limitInput=50;
        editVC.placeHolder=@"请出入新的签名";
        editVC.oldValue=self.moreViewModel.sign;
        editVC.moreViewModel=self.moreViewModel;
        editVC.key=@"recommend";
        editVC.titleText=@"修改个性签名";
        editVC.keyboardType=UIKeyboardTypeDefault;
        [self.navigationController pushViewController:editVC animated:YES];
    }else if (indexPath.section==2&&indexPath.row==0){
        MoreHostEditViewController *editVC= [self.storyboard instantiateViewControllerWithIdentifier:@"HostEditVC"];
        editVC.limitInput=8;
        editVC.placeHolder=@"请出入新的昵称";
        editVC.oldValue=self.moreViewModel.nickname;
        editVC.moreViewModel=self.moreViewModel;
        editVC.key=@"nick_name";
        editVC.titleText=@"修改昵称";
        editVC.keyboardType=UIKeyboardTypeDefault;
        [self.navigationController pushViewController:editVC animated:YES];
    }else if (indexPath.section==3&&indexPath.row==1){
        MoreHostEditViewController *editVC= [self.storyboard instantiateViewControllerWithIdentifier:@"HostEditVC"];
        editVC.limitInput=20;
        editVC.placeHolder=@"请出入新的邮箱";
        editVC.oldValue=self.moreViewModel.email;
        editVC.moreViewModel=self.moreViewModel;
        editVC.key=@"mail";
        editVC.titleText=@"修改邮箱";
        editVC.keyboardType=UIKeyboardTypeEmailAddress;
        [self.navigationController pushViewController:editVC animated:YES];
    }else if (indexPath.section==3&&indexPath.row==2){
        MoreHostEditViewController *editVC= [self.storyboard instantiateViewControllerWithIdentifier:@"HostEditVC"];
        editVC.limitInput=12;
        editVC.placeHolder=@"请出入新的QQ号码";
        editVC.oldValue=self.moreViewModel.qq;
        editVC.moreViewModel=self.moreViewModel;
        editVC.key=@"qq_num";
        editVC.titleText=@"修改QQ";
        editVC.keyboardType=UIKeyboardTypeNumberPad;
        [self.navigationController pushViewController:editVC animated:YES];
    }else if (indexPath.section==2&&indexPath.row==1){
        if (self.sexSettingView==nil) {
            self.sexSettingView=[[[NSBundle mainBundle] loadNibNamed:@"MoreHostSexView" owner:self options:nil] objectAtIndex:0];
            
            [self.sexSettingView.layer setCornerRadius:8.0];
            
            
            

        }
       
            [self.navigationController.view addSubview:self.sexSettingView];
       
       
       
        
        
        
    }
}
- (IBAction)sexChooseMale:(id)sender {
   
    [self.moreViewModel modifyHoseSetting:@"sex" value:@"1"];
    [self.sexSettingView removeFromSuperview];
    
   
   }
- (IBAction)sexChooseFemal:(id)sender {
   
    [UIView setAnimationDuration:0.5];    [self.moreViewModel modifyHoseSetting:@"sex" value:@"0"];
    [self.sexSettingView removeFromSuperview];
  
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
    
    
}
-(void)setUI{
    [self.imgHead setClipsToBounds:YES];
    [self.imgHead.layer setCornerRadius:8.0];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //原始图片
    UIImage *OriginalImage=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    //压缩质量
    NSData *compressed=UIImageJPEGRepresentation([OriginalImage compressedImage],0.5);
    [self.moreViewModel uploadImage:compressed];
//    UIImage *compressedImage=[UIImage imageWithData:compressed];
//    
//    NSLog(@"压缩后图片大小：%d",compressed.length);
    
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (void)dealloc
{
    NSLog(@"HostSettingVC成功被销毁");
}
@end
