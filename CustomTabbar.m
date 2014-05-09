//
//  CustomTabbar.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "CustomTabbar.h"

@implementation CustomTabbar

-(void)awakeFromNib{
    [super awakeFromNib];
    UIColor *tabBackColor=[UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:0.93333];
    CALayer *upsetShadow=[CALayer layer];
    upsetShadow.frame=CGRectMake(0, 0.5, 320, 0.5);
    upsetShadow.backgroundColor=[UIColor grayColor].CGColor;
    self.backgroundColor=tabBackColor;
    [self.layer addSublayer:upsetShadow];
    
    
}
-(void)setSelectItem:(NSInteger)index{
    
}
@end
