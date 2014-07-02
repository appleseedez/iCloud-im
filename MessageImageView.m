//
//  MessageImageView.m
//  itelNSC
//
//  Created by nsc on 14-7-1.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MessageImageView.h"

@implementation MessageImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib{
    UIImageView *redPoint=[[UIImageView alloc]init];
    redPoint.image=[UIImage imageNamed:@"message_little_red_point"];
    redPoint.frame=CGRectMake(4*self.frame.size.width/5.0, 0, self.frame.size.width/2.5, self.frame.size.height/2.5);
    redPoint.center=CGPointMake(self.frame.size.width, 0);
    [self addSubview:redPoint];
    self.redPoint=redPoint;
    __weak id weakSelf=self;
    [RACObserve(self, isNew) subscribeNext:^(NSNumber *x) {
        __strong MessageImageView *strongSelf=weakSelf;
        if ([x boolValue]) {
            strongSelf.redPoint.alpha=1;
        }else{
            strongSelf.redPoint.alpha=0;
        }
        
        
    }];
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
