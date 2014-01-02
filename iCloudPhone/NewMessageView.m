//
//  NewMessageView.m
//  iCloudPhone
//
//  Created by nsc on 13-12-30.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "NewMessageView.h"

@implementation NewMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:frame.size.height/2];
        self.backgroundColor=[UIColor redColor];
    }
    return self;
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
