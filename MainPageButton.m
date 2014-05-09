//
//  MainPageButton.m
//  itelNSC
//
//  Created by nsc on 14-5-9.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MainPageButton.h"

@implementation MainPageButton
-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self addTarget:self action:@selector(transformTo) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(transformBack) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel)];
    
}

-(void)transformTo{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.08];
    self.transform=CGAffineTransformMakeScale(0.95, 0.95);
    [UIView commitAnimations];
}
-(void)transformBack{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.08];
    self.transform=CGAffineTransformMakeScale(1, 1);
    [UIView commitAnimations];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
