//
//  NSCTabbarViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-3-24.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "NSCTabbarViewController.h"

@interface NSCTabbarViewController ()

@end

@implementation NSCTabbarViewController
-(NSArray*)viewControllers{
    if (_viewControllers==nil) {
        UIViewController *first=[self.storyboard instantiateViewControllerWithIdentifier:@"first"];
         UIViewController *second=[self.storyboard instantiateViewControllerWithIdentifier:@"second"];
         UIViewController *third=[self.storyboard instantiateViewControllerWithIdentifier:@"third"];
         UIViewController *fourth=[self.storyboard instantiateViewControllerWithIdentifier:@"fourth"];
         UIViewController *fifth=[self.storyboard instantiateViewControllerWithIdentifier:@"fifth"];
        _viewControllers=@[first,second,third,fourth,fifth];
    }
    
    
    return _viewControllers;
}
-(void)setSelectedIndex:(NSInteger)index{
    UIViewController *v =[self.viewControllers objectAtIndex:index];
    [self.view addSubview:v.view];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
