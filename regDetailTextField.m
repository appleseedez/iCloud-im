//
//  regDetailTextField.m
//  iCloudPhone
//
//  Created by nsc on 13-12-14.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "regDetailTextField.h"

@implementation regDetailTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)setUI{
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:[UIColor colorWithRed:0.8888 green:0.8888 blue:0.8888 alpha:1].CGColor];
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
