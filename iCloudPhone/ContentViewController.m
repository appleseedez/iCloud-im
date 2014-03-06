//
//  ContentViewController.m
//  TV
//
//  Created by nsc on 13-10-24.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ContentViewController.h"
#import "ItelAction.h"
#import "NSCAppDelegate.h"
@interface ContentViewController ()
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong,nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollAd;
@end

@implementation ContentViewController



static int currPage=0;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self addSubButtons];
    self.rootDelegate=((NSCAppDelegate*)[UIApplication sharedApplication].delegate).RootVC;
    self.view.backgroundColor=[UIColor whiteColor];
	// Do any additional setup after loading the view.
}
-(void)addSubButtons{
    float deltaHeight=0.0;
    
    UIButton *btn115=[[UIButton alloc]init];
    btn115.frame=CGRectMake(7, 481,76 , 76);
    [btn115 setImage:[UIImage imageNamed:@"115icon"] forState:UIControlStateNormal];
    [btn115 setBackgroundColor:[UIColor colorWithRed:153.0/255 green:51.0/255 blue:51.0/255 alpha:1]];
    deltaHeight=deltaHeight+btn115.frame.size.height+2*10;
    [btn115 addTarget:self action:@selector(go115) forControlEvents:UIControlEventTouchUpInside];
   // btn115.backgroundColor=[UIColor orangeColor];
    [self.contentScrollView addSubview:btn115];
    
    self.contentScrollView.contentSize=CGSizeMake(self.contentScrollView.contentSize.width, self.contentScrollView.contentSize.height+deltaHeight);
}
- (IBAction)goFish:(id)sender {
    [[ItelAction action ] loginOtherApp:nil];
}
-(void)go115{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"115" bundle:nil];
    if (story) {
        UIViewController *vc115=[story instantiateViewControllerWithIdentifier:@"main115"];
        
        NSCAppDelegate *app=(NSCAppDelegate*)[UIApplication sharedApplication].delegate;
        [app.RootVC presentViewController:vc115 animated:YES completion:^{
            
        }];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (IBAction)changeItel:(id)sender {
    [self.rootDelegate changeSubViewAtIndex:0];
}
- (IBAction)changeCallMessage:(id)sender {
    [self.rootDelegate changeSubViewAtIndex:10];
}
- (IBAction)changeMessage:(id)sender {
    [self.rootDelegate changeSubViewAtIndex:3];
}
- (IBAction)changeContact:(id)sender {
    [self.rootDelegate changeSubViewAtIndex:1];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    currPage = self.scrollAd.contentOffset.x/320;
    self.pageControl.currentPage = currPage;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startTimer];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopTimer];
}
-(void)startTimer{
    self.timer =[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(changeAd) userInfo:nil repeats:YES];
}
-(void)stopTimer{
    [self.timer invalidate];
    self.timer=nil;
}
-(void)changeAd{
    switch (currPage) {
        case 0:
            currPage=1;
            break;
        case 1:
            currPage=2;
            break;
        case 2:
            currPage=0;
            break;
            
        default:
            break;
    }
     [UIView animateWithDuration:0.3 animations:^{
         self.scrollAd.contentOffset=CGPointMake(currPage*320, 0);
     }];
    self.pageControl.currentPage=currPage;
}
@end
