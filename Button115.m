//
//  Button115.m
//  iCloudPhone
//
//  Created by nsc on 14-2-13.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Button115.h"

@implementation Button115

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)setUI{
    [self.layer setCornerRadius:5];
    [self setClipsToBounds:YES];
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
