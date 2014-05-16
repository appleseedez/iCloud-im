//
//  MoreHostSexView.m
//  itelNSC
//
//  Created by nsc on 14-5-16.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreHostSexView.h"

@implementation MoreHostSexView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib{
    [self.mainView.layer setCornerRadius:8.0];
}
- (IBAction)finish:(id)sender {
    [self removeFromSuperview];
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
