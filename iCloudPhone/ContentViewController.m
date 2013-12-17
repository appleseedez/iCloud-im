//
//  ContentViewController.m
//  TV
//
//  Created by nsc on 13-10-24.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ContentViewController.h"
#import "ItelAction.h"
@interface ContentViewController ()
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong,nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollAd;
@end

@implementation ContentViewController



static int currPage;
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.view.backgroundColor=[UIColor whiteColor];
	// Do any additional setup after loading the view.
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
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)startTimer{
    self.timer =[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(changeAd) userInfo:nil repeats:YES];
}
-(void)stopTimer{
    [self.timer invalidate];
    self.timer=nil;
}
-(void)changeAd{
    
}
@end
