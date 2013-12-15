//
//  RegTipLabel.m
//  iCloudPhone
//
//  Created by nsc on 13-12-15.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "RegTipLabel.h"

@implementation RegTipLabel

-(void)setUI{
    UIColor *borderColor=[UIColor colorWithRed:0.875 green:0.698 blue:0.447 alpha:1];
    
    
    
    UIColor *backColor=[UIColor colorWithRed:1 green:0.91 blue:0.78 alpha:1];
    [self.layer setBorderColor:borderColor.CGColor];
    
    [self setBackgroundColor:backColor];
    [self.layer setBorderWidth:1];
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
