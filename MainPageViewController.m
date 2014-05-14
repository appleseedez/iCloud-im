//
//  MainPageViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MainPageViewController.h"
#import "MainTabbarViewController.h"
#import "MainPageButton.h"
#import "MainPageViewModel.h"
#import <UIImageView+AFNetworking.h>

@interface MainPageViewController ()
@property (weak, nonatomic) IBOutlet MainPageButton *btnDialPan;
@property (weak, nonatomic) IBOutlet MainPageButton *btnRecent;
@property (weak, nonatomic) IBOutlet MainPageButton *btnContact;
@property (weak, nonatomic) IBOutlet MainPageButton *btnMessage;
@property (weak, nonatomic) IBOutlet MainPageButton *btnKuaiYU;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong,nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollAd;

@end

@implementation MainPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel=[[MainPageViewModel alloc]init];
    __weak id weekSelf=self;
    //弹出拨号盘按钮
    [[self.btnDialPan rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
       __strong MainPageViewController *strongSelf=weekSelf;
        
        MainTabbarViewController *tabbarVC=(MainTabbarViewController*)strongSelf.tabBarController;
        //[tabbarVC chooseSelectedView:0];
        [tabbarVC presentDialPan];
    }];
    //通话记录按钮
      [[self.btnRecent rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
          __strong MainPageViewController *strongSelf=weekSelf;
           MainTabbarViewController *tabbarVC=(MainTabbarViewController*)strongSelf.tabBarController;
          [tabbarVC chooseSelectedView:0];
      }];
    //消息按钮
    [[self.btnMessage rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        __strong MainPageViewController *strongSelf=weekSelf;
        MainTabbarViewController *tabbarVC=(MainTabbarViewController*)strongSelf.tabBarController;
        [tabbarVC chooseSelectedView:3];
    }];
    //联系人按钮
    [[self.btnContact rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        __strong MainPageViewController *strongSelf=weekSelf;
        MainTabbarViewController *tabbarVC=(MainTabbarViewController*)strongSelf.tabBarController;
        [tabbarVC chooseSelectedView:1];
    }];
    //快鱼按钮
    [[self.btnKuaiYU rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
       // __strong MainPageViewController *strongSelf=weekSelf;
       
    }];
    //监听 广告数组
     [RACObserve(self, viewModel.adArray)subscribeNext:^(NSArray *x) {
         __strong MainPageViewController *strongSelf=weekSelf;
         if ([x count]) {
         
             UIEdgeInsets insets;
             insets.left=0;
             insets.right=[x count]*320;
             insets.bottom=strongSelf.scrollAd.frame.size.height;
             insets.top=0;
             strongSelf.scrollAd.contentInset=insets;
             for (int i=0; i<[x count]; i++) {
                 float height=strongSelf.scrollAd.bounds.size.height;
                 UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(320*i, 0, 320, height)];
//                 __weak UIImageView *weakImage=image;
//                 [RACObserve(image, image) subscribeNext:^(UIImage *x) {
//                     __strong UIImageView *strongImage=weakImage;
//                     if (x==nil) {
//                         MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongImage animated:YES];
//                         hud.labelText=@"加载中...";
//                     }else{
//                         [MBProgressHUD hideHUDForView:strongImage animated:YES];
//                     }
//                 }];
                 [image setImageWithURL:[NSURL URLWithString: [x objectAtIndex:i ] ]];
                 [strongSelf.scrollAd addSubview:image];
                 strongSelf.pageControl.numberOfPages=[x count];
                 [strongSelf startTimer];
             }
             
         }else{
             [strongSelf.viewModel loadAdvertises];
         }
     }];
    //监听 加载广告
    [RACObserve(self, viewModel.loadingAD) subscribeNext:^(NSNumber *x) {
        __strong MainPageViewController *strongSelf=weekSelf;
        if ([x boolValue]) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.scrollAd animated:YES];
           
            hud.labelText=@"玩命加载中....";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.scrollAd animated:YES];
        }
    }];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self.viewModel.adArray count]) {
        [self startTimer];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopTimer];
}
-(void)startTimer{
    if (self.timer) {
        return;
    }
    self.timer =[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(changeAd) userInfo:nil repeats:YES];
}
-(void)stopTimer{
    [self.timer invalidate];
    self.timer=nil;
}
static int currPage=0;
-(void)changeAd{
    
    if ([self.viewModel.adArray count]) {
        if (currPage<[self.viewModel.adArray count]-1) {
            currPage++;
        }else{
            currPage=0;
        }
    }else{
        currPage=0;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollAd.contentOffset=CGPointMake(currPage*320, 0);
    }];
    self.pageControl.currentPage=currPage;
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    currPage = self.scrollAd.contentOffset.x/320;
    self.pageControl.currentPage = currPage;
    
}
- (void)dealloc
{
    NSLog(@"mainPageVC 被成功销毁");
}
@end
