//
//  DialNumberButton.m
//  DIalViewSence
//
//  Created by nsc on 14-4-28.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "DialNumberButton.h"

@implementation DialNumberButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(void)setUI{
    [self.layer setCornerRadius:self.frame.size.height/2.0];
    [self.layer setBorderColor:self.borderColor.CGColor];
    [self.layer setBorderWidth:1];
    [self setBackgroundColor:self.normalColor];
    [self addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)click:(DialNumberButton*)sender{
    [UIView animateWithDuration:0.3 animations:^{
        sender.backgroundColor=self.highColor;
    } completion:^(BOOL finished) {
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:0.3];
        sender.backgroundColor=self.normalColor;
        [UIView commitAnimations];
    }] ;
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
