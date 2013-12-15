//
//  RegNextButton.m
//  iCloudPhone
//
//  Created by nsc on 13-12-11.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "RegNextButton.h"

@implementation RegNextButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)setUI{
      UIColor *color = [UIColor colorWithRed:0 green:0.4 blue:1 alpha:1];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.backgroundColor=color;
    self.bounds=CGRectMake(0, 0, 310, 44.5);
    //[self setTitle:@"下一步" forState:UIControlStateNormal];
    [self addTarget:self action:@selector(changBackGroundHigh) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(changBackGroundNormal) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(changBackGroundNormal) forControlEvents:UIControlEventTouchUpOutside];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.layer setCornerRadius:5.0];
}
-(void)changBackGroundNormal{
    
     UIColor *color = [UIColor colorWithRed:0 green:0.4 blue:1 alpha:1];
            self.backgroundColor=color;
   
}
-(void)changBackGroundHigh{
   
   UIColor *high=[UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:1];
    
    self.backgroundColor=high;
    
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
