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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollAd;
@end

@implementation ContentViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.view.backgroundColor=[UIColor whiteColor];
	// Do any additional setup after loading the view.
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    int page = self.scrollAd.contentOffset.x/320;
    self.pageControl.currentPage = page;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
